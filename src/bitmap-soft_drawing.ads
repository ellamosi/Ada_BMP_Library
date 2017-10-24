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

--  This package provides a software implementation of the Bitmap.Buffer drawing
--  primitives.

with Bitmap.Buffer; use Bitmap.Buffer;

package Bitmap.Soft_Drawing is

   subtype Parent is Bitmap_Buffer;

   type Soft_Drawing_Bitmap_Buffer is abstract new Parent with null record;

   type Any_Soft_Drawing_Bitmap_Buffer is
     access all Soft_Drawing_Bitmap_Buffer'Class;

   overriding
   procedure Draw_Line
     (Buffer      : in out Soft_Drawing_Bitmap_Buffer;
      Color       : UInt32;
      Start, Stop : Point;
      Thickness   : Natural := 1;
      Fast        : Boolean := True);

   overriding
   procedure Draw_Line
     (Buffer      : in out Soft_Drawing_Bitmap_Buffer;
      Color       : Bitmap_Color;
      Start, Stop : Point;
      Thickness   : Natural := 1;
      Fast        : Boolean := True);

   overriding
   procedure Fill
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : Bitmap_Color);
   --  Fill the specified buffer with 'Color'

   overriding
   procedure Fill
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : UInt32);
   --  Same as above, using the destination buffer native color representation

   overriding
   procedure Fill_Rect
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : Bitmap_Color;
      Area   : Rect);
   --  Fill the specified area of the buffer with 'Color'

   overriding
   procedure Fill_Rect
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : UInt32;
      Area   : Rect);
   --  Same as above, using the destination buffer native color representation

   overriding
   procedure Copy_Rect
     (Src_Buffer  : Bitmap_Buffer'Class;
      Src_Pt      : Point;
      Dst_Buffer  : in out Soft_Drawing_Bitmap_Buffer;
      Dst_Pt      : Point;
      Bg_Buffer   : Bitmap_Buffer'Class;
      Bg_Pt       : Point;
      Width       : Natural;
      Height      : Natural;
      Synchronous : Boolean);

   overriding
   procedure Copy_Rect
     (Src_Buffer  : Bitmap_Buffer'Class;
      Src_Pt      : Point;
      Dst_Buffer  : in out Soft_Drawing_Bitmap_Buffer;
      Dst_Pt      : Point;
      Width       : Natural;
      Height      : Natural;
      Synchronous : Boolean);

   overriding
   procedure Copy_Rect_Blend
     (Src_Buffer  : Soft_Drawing_Bitmap_Buffer;
      Src_Pt      : Point;
      Dst_Buffer  : in out Bitmap_Buffer'Class;
      Dst_Pt      : Point;
      Width       : Natural;
      Height      : Natural;
      Synchronous : Boolean);

   overriding
   procedure Draw_Vertical_Line
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : UInt32;
      Pt     : Point;
      Height : Integer);

   overriding
   procedure Draw_Vertical_Line
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : Bitmap_Color;
      Pt     : Point;
      Height : Integer);

   overriding
   procedure Draw_Horizontal_Line
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : UInt32;
      Pt     : Point;
      Width  : Integer);

   overriding
   procedure Draw_Horizontal_Line
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : Bitmap_Color;
      Pt     : Point;
      Width  : Integer);

   overriding
   procedure Draw_Rect
     (Buffer    : in out Soft_Drawing_Bitmap_Buffer;
      Color     : Bitmap_Color;
      Area      : Rect;
      Thickness : Natural := 1);
   --  Draws a rectangle

   overriding
   procedure Draw_Rounded_Rect
     (Buffer    : in out Soft_Drawing_Bitmap_Buffer;
      Color     : Bitmap_Color;
      Area      : Rect;
      Radius    : Natural;
      Thickness : Natural := 1);

   overriding
   procedure Fill_Rounded_Rect
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : Bitmap_Color;
      Area   : Rect;
      Radius : Natural);

   overriding
   procedure Draw_Circle
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : UInt32;
      Center : Point;
      Radius : Natural);

   overriding
   procedure Draw_Circle
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : Bitmap_Color;
      Center : Point;
      Radius : Natural);

   overriding
   procedure Fill_Circle
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : UInt32;
      Center : Point;
      Radius : Natural);

   overriding
   procedure Fill_Circle
     (Buffer : in out Soft_Drawing_Bitmap_Buffer;
      Color  : Bitmap_Color;
      Center : Point;
      Radius : Natural);

   overriding
   procedure Cubic_Bezier
     (Buffer         : in out Soft_Drawing_Bitmap_Buffer;
      Color          : Bitmap_Color;
      P1, P2, P3, P4 : Point;
      N              : Positive := 20;
      Thickness      : Natural := 1);

end Bitmap.Soft_Drawing;