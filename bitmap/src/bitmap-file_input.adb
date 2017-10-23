with Interfaces;    use Interfaces;
--   with Bitmap.Buffer; use Bitmap.Buffer;
with Bitmap.Memory_Mapped; use Bitmap.Memory_Mapped;

package body Bitmap.File_Input is

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
      Hdr    : Header;
      Inf    : Info;

      RGB_Pix : Bitmap_Color;
      Pix_In  : UInt8_Array (1 .. 3);

      Input_Stream : Ada.Streams.Stream_IO.Stream_Access;

--        function Allocate_Bitmap return not null Any_Bitmap_Buffer is
--           type Pixel_Data is new Bitmap.UInt16_Array (1 .. BM_Height * BM_Height) with Pack;
--           BM : constant Any_Memory_Mapped_Bitmap_Buffer := new Memory_Mapped_Bitmap_Buffer;
--           Data : constant access Pixel_Data := new Pixel_Data;
--        begin
--           BM.Actual_Width := BM_Width;
--           BM.Actual_Height := BM_Height;
--           BM.Actual_Color_Mode := RGB_565;
--           BM.Currently_Swapped := False;
--           BM.Addr := Data.all'Address;
--           return Any_Bitmap_Buffer (BM);
--        end Allocate_Bitmap;
   begin
      Input_Stream := Ada.Streams.Stream_IO.Stream (File);
      UInt8_Array'Read (Input_Stream, Hdr.Arr);
      UInt8_Array'Read (Input_Stream, Inf.Arr);
--        Hdr.Signature := 16#4D42#;
--        Hdr.Size      := (Data_Size + 54) / 4;
--        Hdr.Reserved1 := 0;
--        Hdr.Reserved2 := 0;
--        Hdr.Offset    := 54;

--        Inf.Struct_Size := 40;
--        Inf.Width := Integer_32 (Bitmap.Width);
--        Inf.Height := Integer_32 (Bitmap.Height);
--        Inf.Planes := 1;
--        Inf.Pixel_Size := 24;
--        Inf.Compression := 0;
--        Inf.Image_Size := Data_Size / 4;
--        Inf.PPMX := 2835;
--        Inf.PPMY := 2835;
--        Inf.Palette_Size := 0;
--        Inf.Important := 0;

      Set_Index (File, Positive_Count (Hdr.Offset));

      declare
         Width  : constant Integer := Integer (Inf.Width);
         Height : constant Integer := Integer (Inf.Height);

         Row_Size    : constant Integer_32 := Integer_32 (Width * 24);
         Row_Padding : constant Integer_32 := (32 - (Row_Size mod 32)) mod 32 / 8;

         Padding : UInt8_Array (1 .. Integer (Row_Padding));

         type Pixel_Data is new Bitmap.UInt16_Array (1 .. Width * Height) with Pack;
         BM : constant Any_Memory_Mapped_Bitmap_Buffer := new Memory_Mapped_Bitmap_Buffer;
         Data : constant access Pixel_Data := new Pixel_Data;
      begin
         BM.Actual_Width := Width;
         BM.Actual_Height := Height;
         BM.Actual_Color_Mode := RGB_565;
         BM.Currently_Swapped := False;
         BM.Addr := Data.all'Address;

         for Y in reverse 0 .. Height - 1 loop
            for X in 0 .. Width - 1 loop
               UInt8_Array'Read (Input_Stream, Pix_In);
               --  RGB_Pix := Bitmap.Pixel ((X, Y));

               RGB_Pix.Blue  := Pix_In (1);
               RGB_Pix.Green := Pix_In (2);
               RGB_Pix.Red   := Pix_In (3);

               BM.Set_Pixel ((X, Y), RGB_Pix);
            end loop;

            UInt8_Array'Read (Input_Stream, Padding);
         end loop;
         return Any_Bitmap_Buffer (BM);
      end;
   end Read_BMP_File;

end Bitmap.File_Input;
