------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2015-2017, AdaCore                     --
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

with System;

package Bitmap.Buffer is

   type Bitmap_Buffer is interface;

   type Any_Bitmap_Buffer is access all Bitmap_Buffer'Class;

   function Width (Buffer : Bitmap_Buffer) return Natural is abstract;
   --  Width of the buffer. Note that it's the user-visible width
   --  (see below for the meaning of the Swapped value).

   function Height (Buffer : Bitmap_Buffer) return Natural is abstract;
   --  Height of the buffer. Note that it's the user-visible height
   --  (see below for the meaning of the Swapped value).

   function Swapped (Buffer : Bitmap_Buffer) return Boolean is abstract;
   --  If Swapped return True, operations on this buffer will consider:
   --  Width0 = Height
   --  Height0 = Width
   --  Y0 = Buffer.Width - X - 1
   --  X0 = Y
   --
   --  As an example, the Bitmap buffer that corresponds to a 240x320
   --  swapped display (to display images in landscape mode) with have
   --  the following values:
   --  Width => 320
   --  Height => 240
   --  Swapped => True
   --  So Put_Pixel (Buffer, 30, 10, Color) will place the pixel at
   --  Y0 = 320 - 30 - 1 = 289
   --  X0 = 10

   function Color_Mode (Buffer : Bitmap_Buffer) return Bitmap_Color_Mode is abstract;
   --  The buffer color mode. Note that not all color modes are supported by
   --  the hardware acceleration (if any), so you need to check your actual
   --  hardware to optimize buffer transfers.

   function Mapped_In_RAM (Buffer : Bitmap_Buffer) return Boolean is abstract;
   --  Return True is the bitmap is storred in the CPU address space

   function Memory_Address (Buffer : Bitmap_Buffer) return System.Address is abstract
     with Pre'Class => Buffer.Mapped_In_RAM;
   --  Return the address of the bitmap in the CPU address space. If the bitmap
   --  is not in the CPU address space, the result is undefined.

   procedure Set_Pixel
     (Buffer  : in out Bitmap_Buffer;
      Pt      : Point;
      Value   : Bitmap_Color) is abstract;

   procedure Set_Pixel
     (Buffer  : in out Bitmap_Buffer;
      Pt      : Point;
      Value   : UInt32) is abstract;

   procedure Set_Pixel_Blend
     (Buffer : in out Bitmap_Buffer;
      Pt      : Point;
      Value  : Bitmap_Color) is abstract;

   function Pixel
     (Buffer : Bitmap_Buffer;
      Pt     : Point)
      return Bitmap_Color is abstract;

   function Pixel
     (Buffer : Bitmap_Buffer;
      Pt     : Point)
      return UInt32 is abstract;

   procedure Draw_Line
     (Buffer      : in out Bitmap_Buffer;
      Color       : UInt32;
      Start, Stop : Point;
      Thickness   : Natural := 1;
      Fast        : Boolean := True) is abstract;

   procedure Draw_Line
     (Buffer      : in out Bitmap_Buffer;
      Color       : Bitmap_Color;
      Start, Stop : Point;
      Thickness   : Natural := 1;
      Fast        : Boolean := True) is abstract;
   --  If fast is set, then the line thickness uses squares to draw, while
   --  if not set, then the line will be composed of circles, much slower to
   --  draw but providing nicer line cap.

   procedure Fill
     (Buffer : in out Bitmap_Buffer;
      Color  : Bitmap_Color) is abstract;
   --  Fill the specified buffer with 'Color'

   procedure Fill
     (Buffer : in out Bitmap_Buffer;
      Color  : UInt32) is abstract;
   --  Same as above, using the destination buffer native color representation

   procedure Fill_Rect
     (Buffer : in out Bitmap_Buffer;
      Color  : Bitmap_Color;
      Area   : Rect) is abstract;
   --  Fill the specified area of the buffer with 'Color'

   procedure Fill_Rect
     (Buffer : in out Bitmap_Buffer;
      Color  : UInt32;
      Area   : Rect) is abstract;
   --  Same as above, using the destination buffer native color representation

   procedure Copy_Rect
     (Src_Buffer  : Bitmap_Buffer'Class;
      Src_Pt      : Point;
      Dst_Buffer  : in out Bitmap_Buffer;
      Dst_Pt      : Point;
      Bg_Buffer   : Bitmap_Buffer'Class;
      Bg_Pt       : Point;
      Width       : Natural;
      Height      : Natural;
      Synchronous : Boolean) is abstract;

   procedure Copy_Rect
     (Src_Buffer  : Bitmap_Buffer'Class;
      Src_Pt      : Point;
      Dst_Buffer  : in out Bitmap_Buffer;
      Dst_Pt      : Point;
      Width       : Natural;
      Height      : Natural;
      Synchronous : Boolean) is abstract;

   procedure Copy_Rect_Blend
     (Src_Buffer  : Bitmap_Buffer;
      Src_Pt      : Point;
      Dst_Buffer  : in out Bitmap_Buffer'Class;
      Dst_Pt      : Point;
      Width       : Natural;
      Height      : Natural;
      Synchronous : Boolean) is abstract;

   procedure Draw_Vertical_Line
     (Buffer : in out Bitmap_Buffer;
      Color  : UInt32;
      Pt     : Point;
      Height : Integer) is abstract;

   procedure Draw_Vertical_Line
     (Buffer : in out Bitmap_Buffer;
      Color  : Bitmap_Color;
      Pt     : Point;
      Height : Integer) is abstract;

   procedure Draw_Horizontal_Line
     (Buffer : in out Bitmap_Buffer;
      Color  : UInt32;
      Pt     : Point;
      Width  : Integer) is abstract;

   procedure Draw_Horizontal_Line
     (Buffer : in out Bitmap_Buffer;
      Color  : Bitmap_Color;
      Pt     : Point;
      Width  : Integer) is abstract;

   procedure Draw_Rect
     (Buffer    : in out Bitmap_Buffer;
      Color     : Bitmap_Color;
      Area      : Rect;
      Thickness : Natural := 1) is abstract;
   --  Draws a rectangle

   procedure Draw_Rounded_Rect
     (Buffer    : in out Bitmap_Buffer;
      Color     : Bitmap_Color;
      Area      : Rect;
      Radius    : Natural;
      Thickness : Natural := 1) is abstract;

   procedure Fill_Rounded_Rect
     (Buffer : in out Bitmap_Buffer;
      Color  : Bitmap_Color;
      Area   : Rect;
      Radius : Natural) is abstract;

   procedure Draw_Circle
     (Buffer : in out Bitmap_Buffer;
      Color  : UInt32;
      Center : Point;
      Radius : Natural) is abstract;

   procedure Draw_Circle
     (Buffer : in out Bitmap_Buffer;
      Color  : Bitmap_Color;
      Center : Point;
      Radius : Natural) is abstract;

   procedure Fill_Circle
     (Buffer : in out Bitmap_Buffer;
      Color  : UInt32;
      Center : Point;
      Radius : Natural) is abstract;

   procedure Fill_Circle
     (Buffer : in out Bitmap_Buffer;
      Color  : Bitmap_Color;
      Center : Point;
      Radius : Natural) is abstract;

   procedure Cubic_Bezier
     (Buffer         : in out Bitmap_Buffer;
      Color          : Bitmap_Color;
      P1, P2, P3, P4 : Point;
      N              : Positive := 20;
      Thickness      : Natural := 1) is abstract;

   function Buffer_Size (Buffer : Bitmap_Buffer) return Natural is abstract;

end Bitmap.Buffer;
