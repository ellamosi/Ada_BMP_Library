------------------------------------------------------------------------------
--                                                                          --
--                        Copyright (C) 2017, AdaCore                       --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with Interfaces;           use Interfaces;
with Bitmap.Memory_Mapped; use Bitmap.Memory_Mapped;
with System;

package body Bitmap.File_IO is

   type Header (As_Array : Boolean := True) is record
      case As_Array is
         when True =>
            Arr : UInt8_Array (1 .. 14);
         when False =>
            Signature : Integer_16;
            Size      : Integer_32; --  File size
            Reserved1 : Integer_16;
            Reserved2 : Integer_16;
            Offset    : Integer_32; --  Data offset
      end case;
   end record with Unchecked_Union, Pack, Size => 14 * 8;

   type Info (As_Array : Boolean := True) is record
      case As_Array is
         when True =>
            Arr : UInt8_Array (1 .. 40);
         when False =>
            Struct_Size   : Integer_32;
            Width         : Integer_32; -- Image width in pixels
            Height        : Integer_32; -- Image hieght in pixels
            Planes        : Integer_16;
            Pixel_Size    : Integer_16; -- Bits per pixel
            Compression   : Integer_32; -- Zero means no compression
            Image_Size    : Integer_32; -- Size of the image data in UInt8s
            PPMX          : Integer_32; -- Pixels per meter in x led
            PPMY          : Integer_32; -- Pixels per meter in y led
            Palette_Size  : Integer_32; -- Number of colors
            Important     : Integer_32;
      end case;
   end record with Unchecked_Union, Pack, Size => 40 * 8;

   -------------------
   -- Read_BMP_File --
   -------------------

   function Read_BMP_File (File : File_Type) return not null Any_Bitmap_Buffer
   is
      function Allocate_Pixel_Data return System.Address;
      procedure Read_Pixel_Data;

      Input_Stream : Ada.Streams.Stream_IO.Stream_Access;

      Hdr : Header;
      Inf : Info;

      Width  : Integer;
      Height : Integer;

      BM : constant Any_Memory_Mapped_Bitmap_Buffer := new Memory_Mapped_Bitmap_Buffer;

      RGB_Pix : Bitmap_Color;
      Pix_In  : UInt8_Array (1 .. 3);

      -------------------------
      -- Allocate_Pixel_Data --
      -------------------------

      function Allocate_Pixel_Data return System.Address is
         type Pixel_Data is new Bitmap.UInt16_Array (1 .. Width * Height) with Pack;
         type Pixel_Data_Access is access Pixel_Data;
         Data : constant Pixel_Data_Access := new Pixel_Data;
      begin
         return Data.all'Address;
      end Allocate_Pixel_Data;

      ---------------------
      -- Read_Pixel_Data --
      ---------------------

      procedure Read_Pixel_Data is
         Row_Size    : constant Integer_32 := Integer_32 (Width * 24);
         Row_Padding : constant Integer_32 := (32 - (Row_Size mod 32)) mod 32 / 8;

         Padding : UInt8_Array (1 .. Integer (Row_Padding));
      begin
         for Y in reverse 0 .. Height - 1 loop
            for X in 0 .. Width - 1 loop
               UInt8_Array'Read (Input_Stream, Pix_In);

               RGB_Pix.Blue  := Pix_In (1);
               RGB_Pix.Green := Pix_In (2);
               RGB_Pix.Red   := Pix_In (3);

               BM.Set_Pixel ((X, Y), RGB_Pix);
            end loop;

            UInt8_Array'Read (Input_Stream, Padding);
         end loop;
      end Read_Pixel_Data;
   begin
      Input_Stream := Ada.Streams.Stream_IO.Stream (File);
      UInt8_Array'Read (Input_Stream, Hdr.Arr);
      UInt8_Array'Read (Input_Stream, Inf.Arr);

      Width  := Integer (Inf.Width);
      Height := Integer (Inf.Height);

      BM.Actual_Width := Width;
      BM.Actual_Height := Height;
      BM.Actual_Color_Mode := RGB_565;
      BM.Currently_Swapped := False;
      BM.Addr := Allocate_Pixel_Data;

      Set_Index (File, Positive_Count (Hdr.Offset + 1));
      Read_Pixel_Data;

      return Any_Bitmap_Buffer (BM);
   end Read_BMP_File;

   --------------------
   -- Write_BMP_File --
   --------------------

   procedure Write_BMP_File (File   : File_Type;
                             Bitmap : Bitmap_Buffer'Class)
   is
      Hdr    : Header;
      Inf    : Info;

      Row_Size    : constant Integer_32 := Integer_32 (Bitmap.Width * 24);
      Row_Padding : constant Integer_32 := (32 - (Row_Size mod 32)) mod 32 / 8;
      Data_Size   : constant Integer_32 := (Row_Size + Row_Padding) * Integer_32 (Bitmap.Height);

      RGB_Pix : Bitmap_Color;
      Pix_Out : UInt8_Array (1 .. 3);
      Padding : constant UInt8_Array (1 .. Integer (Row_Padding)) := (others => 0);

      Output_Stream : Ada.Streams.Stream_IO.Stream_Access;
   begin
      Hdr.Signature := 16#4D42#;
      Hdr.Size      := (Data_Size + 54) / 4;
      Hdr.Reserved1 := 0;
      Hdr.Reserved2 := 0;
      Hdr.Offset    := 54;

      Inf.Struct_Size := 40;
      Inf.Width := Integer_32 (Bitmap.Width);
      Inf.Height := Integer_32 (Bitmap.Height);
      Inf.Planes := 1;
      Inf.Pixel_Size := 24;
      Inf.Compression := 0;
      Inf.Image_Size := Data_Size / 4;
      Inf.PPMX := 2835;
      Inf.PPMY := 2835;
      Inf.Palette_Size := 0;
      Inf.Important := 0;

      Output_Stream := Ada.Streams.Stream_IO.Stream (File);
      UInt8_Array'Write (Output_Stream, Hdr.Arr);
      UInt8_Array'Write (Output_Stream, Inf.Arr);

      for Y in reverse 0 .. Bitmap.Height - 1 loop
         for X in 0 .. Bitmap.Width - 1 loop

            RGB_Pix := Bitmap.Pixel ((X, Y));

            Pix_Out (1) := RGB_Pix.Blue;
            Pix_Out (2) := RGB_Pix.Green;
            Pix_Out (3) := RGB_Pix.Red;

            UInt8_Array'Write (Output_Stream, Pix_Out);
         end loop;

         UInt8_Array'Write (Output_Stream, Padding);
      end loop;
   end Write_BMP_File;

end Bitmap.File_IO;
