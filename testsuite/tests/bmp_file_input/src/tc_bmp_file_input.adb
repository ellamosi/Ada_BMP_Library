with Test_Directories;      use Test_Directories;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Bitmap;                use Bitmap;
with Bitmap.Buffer;         use Bitmap.Buffer;
with Bitmap.File_IO;        use Bitmap.File_IO;
with Bitmap.Memory_Mapped;  use Bitmap.Memory_Mapped;

procedure TC_BMP_File_Input is
   function Bitmaps_Equal return Boolean;
   function Allocate_Bitmap return not null Any_Bitmap_Buffer;

   BM_Width  : constant := 100;
   BM_Height : constant := 100;

   ---------------------
   -- Allocate_Bitmap --
   ---------------------

   function Allocate_Bitmap return not null Any_Bitmap_Buffer is
      type Pixel_Data is new Bitmap.UInt16_Array (1 .. BM_Height * BM_Height) with Pack;
      BM : constant Any_Memory_Mapped_Bitmap_Buffer := new Memory_Mapped_Bitmap_Buffer;
      Data : constant access Pixel_Data := new Pixel_Data;
   begin
      BM.Actual_Width := BM_Width;
      BM.Actual_Height := BM_Height;
      BM.Actual_Color_Mode := RGB_565;
      BM.Currently_Swapped := False;
      BM.Addr := Data.all'Address;
      return Any_Bitmap_Buffer (BM);
   end Allocate_Bitmap;

   BMP_File : Ada.Streams.Stream_IO.File_Type;
   BM1 : constant not null Any_Bitmap_Buffer := Allocate_Bitmap;
   BM2 : Any_Bitmap_Buffer;

   -------------------
   -- Bitmaps_Equal --
   -------------------

   function Bitmaps_Equal return Boolean is
      RGB_Pix1, RGB_Pix2 : Bitmap_Color;
   begin
      if BM1.Width /= BM2.Width then return False; end if;
      if BM1.Height /= BM2.Height then return False; end if;
      for Y in 0 .. BM1.Height - 1 loop
         for X in 0 .. BM1.Width - 1 loop
            RGB_Pix1 := BM1.Pixel ((X, Y));
            RGB_Pix2 := BM2.Pixel ((X, Y));
            if  RGB_Pix1.Red   /= RGB_Pix2.Red   then return False; end if;
            if  RGB_Pix1.Green /= RGB_Pix2.Green then return False; end if;
            if  RGB_Pix1.Blue  /= RGB_Pix2.Blue  then return False; end if;
         end loop;
      end loop;
      return True;
   end Bitmaps_Equal;
begin
   BM1.Fill (Black);
   BM1.Fill_Rounded_Rect (Color  => Green,
                          Area   => ((5, 5), BM_Width / 2, BM_Height / 2),
                          Radius => 10);

   BM1.Draw_Rounded_Rect (Color  => Red,
                         Area   => ((5, 5), BM_Width / 2, BM_Height / 2),
                         Radius => 10,
                         Thickness => 3);

   BM1.Fill_Circle (Color  => Yellow,
                   Center => (BM_Width / 2, BM_Height / 2),
                   Radius => BM_Width / 4);

   BM1.Draw_Circle (Color  => Blue,
                   Center => (BM_Width / 2, BM_Height / 2),
                   Radius => BM_Width / 4);

   BM1.Cubic_Bezier (Color     => Violet,
                    P1        => (5, 5),
                    P2        => (0, BM_Height / 2),
                    P3        => (BM_Width / 2, BM_Height / 2),
                    P4        => (BM_Width - 5, BM_Height - 5),
                    N         => 100,
                    Thickness => 3);

   BM1.Draw_Line (Color     => White,
                 Start     => (0, 0),
                 Stop      => (BM_Width - 1, BM_Height / 2),
                 Thickness => 1,
                 Fast      => True);

   BM1.Set_Pixel ((0, 0), Red);
   BM1.Set_Pixel ((0, 1), Green);
   BM1.Set_Pixel ((0, 2), Blue);

   Copy_Rect (Src_Buffer  => BM1.all,
              Src_Pt      => (0, 0),
              Dst_Buffer  => BM1.all,
              Dst_Pt      => (0, BM_Height / 2 + 10),
              Width       => BM_Width / 4,
              Height      => BM_Height / 4,
              Synchronous => True);

   Open (File => BMP_File, Mode => In_File, Name => Test_Dir & "/ref.bmp");
   BM2 := Read_BMP_File (BMP_File);
   Close (BMP_File);

   if not Bitmaps_Equal
   then
      Put_Line ("BMP file reading test FAILED.");
      Put_Line ("Input BMP content is different than generated drawing.");
      Put_Line ("This could mean that:");
      Put_Line (" 1 - Bitmap drawing is broken");
      Put_Line (" 2 - Bitmap file input is broken");
      Put_Line (" 3 - You changed/improved bitmap drawing");
      New_Line;
      Put_Line ("When 1 or 2, please fix the problem,");
      Put_Line ("When 3 please update the reference bitmap and exaplaining" &
                  " the changes you made.");
   else
      Put_Line ("BMP file reading test OK");
   end if;
end TC_BMP_File_Input;
