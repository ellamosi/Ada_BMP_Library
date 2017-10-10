private with Ada.Containers.Vectors;
private with Ada.Direct_IO;
private with Ada.Strings.Unbounded;

with Interfaces; use Interfaces;

--  Simple wrappers around the Ada standard library to provide implementations
--  for HAL.Filesystem interfaces.

package Bitmap.Filesystem is

   subtype Pathname is String;

   type File_Kind is (Regular_File, Directory);

   type File_Mode is (Read_Only, Write_Only, Read_Write);

   type Status_Kind is (Status_Ok,
                        Symbolic_Links_Loop,
                        Permission_Denied,
                        Input_Output_Error,
                        No_Such_File_Or_Directory,
                        Filename_Is_Too_Long,
                        Not_A_Directory,
                        Representation_Overflow,
                        Invalid_Argument,
                        Not_Enough_Space,
                        Not_Enough_Memory,
                        Bad_Address,
                        File_Exists,
                        Read_Only_File_System,
                        Operation_Not_Permitted,
                        No_Space_Left_On_Device,
                        Too_Many_Links,
                        Resource_Busy,
                        Buffer_Is_Too_Small,
                        Read_Would_Block,
                        Call_Was_Interrupted);

   type User_ID is new Natural;
   type Group_ID is new Natural;
   type IO_Count is new Unsigned_64;


   type FS_Driver is tagged limited private;
   type FS_Driver_Ref is access FS_Driver;
--     type FS_Driver is limited interface;
--     type Any_FS_Driver is access all FS_Driver'Class;
   --  Interface to provide access a filesystem

   --  type File_Handle is tagged limited null record;
   --  type Any_File_Handle is access all File_Handle'Class;
   --  Interface to provide access to a regular file
   type File_Handle is tagged limited private;
   type Any_File_Handle is access all File_Handle'Class;
   type File_Handle_Ref is access File_Handle;

   type Directory_Handle is tagged limited private;
   type Any_Directory_Handle is access all Directory_Handle'Class;
   type Directory_Handle_Ref is access Directory_Handle;
   --  type Native_Directory_Handle is limited new Directory_Handle with private;
   --  Interface to provide access to a directory

   ----------------------
   -- Native_FS_Driver --
   ----------------------

   procedure Destroy (This : in out FS_Driver_Ref);

   function Create
     (FS       : out FS_Driver;
      Root_Dir : Pathname)
      return Status_Kind;
   --  Create a Native_FS_Driver considering Root_Dir as its root directory.
   --  All other pathnames in this API are processed as relative to it.
   --
   --  Note that this does not provide real isolation: trying to access the
   --  ".." directory will access the parent of the root directory, not the
   --  root directory itself.

   function Create_Node
     (This : in out FS_Driver;
      Path : Pathname;
      Kind : File_Kind)
      return Status_Kind;

   function Create_Directory
     (This : in out FS_Driver;
      Path : Pathname)
      return Status_Kind;

   function Unlink
     (This : in out FS_Driver;
      Path : Pathname)
      return Status_Kind;

   function Remove_Directory
     (This : in out FS_Driver;
      Path : Pathname)
      return Status_Kind;

   function Rename
     (This     : in out FS_Driver;
      Old_Path : Pathname;
      New_Path : Pathname)
      return Status_Kind;

   function Truncate_File
     (This   : in out FS_Driver;
      Path   : Pathname;
      Length : IO_Count)
      return Status_Kind;

   function Open
     (This   : in out FS_Driver;
      Path   : Pathname;
      Mode   : File_Mode;
      Handle : out Any_File_Handle)
      return Status_Kind;

   function Open_Directory
     (This   : in out FS_Driver;
      Path   : Pathname;
      Handle : out Any_Directory_Handle)
      return Status_Kind;

   -----------------
   -- File_Handle --
   -----------------

   function Read
     (This : in out File_Handle;
      Data : out UInt8_Array)
      return Status_Kind;

   function Write
     (This : in out File_Handle;
      Data : UInt8_Array)
      return Status_Kind;

   function Seek
     (This   : in out File_Handle;
      Offset : IO_Count)
      return Status_Kind;

   function Close
     (This : in out File_Handle)
      return Status_Kind;

   ----------------------
   -- Directory_Handle --
   ----------------------

   type Directory_Entry is record
      Entry_Type  : File_Kind;
   end record;

   function Read_Entry
     (This         : in out Directory_Handle;
      Entry_Number : Positive;
      Dir_Entry    : out Directory_Entry)
      return Status_Kind;

   function Entry_Name
     (This         : in out Directory_Handle;
      Entry_Number : Positive)
      return Pathname;

   function Close
     (This : in out Directory_Handle)
      return Status_Kind;

   -------------
   -- Helpers --
   -------------

   function Join
     (Prefix, Suffix           : Pathname;
      Ignore_Absolute_Suffixes : Boolean)
      return Pathname;
   --  Like Ada.Directories.Compose, but also accepts a full path as Suffix.
   --  For instance:
   --
   --     Join ("/a", "b")   => "/a/b"
   --     Join ("/a", "b/c") => "/a/b/c"
   --
   --  If Ignore_Absolute_Suffixes is True, if Suffix is an absolute path, do
   --  as if it was a relative path instead:
   --
   --     Join ("/a", "/b")  => "/a/b"
   --
   --  Otherwise, if sufifx is an absolute path, just return Suffix.

private

   package Byte_IO is new Ada.Direct_IO (UInt8);

   type FS_Driver is tagged limited record
      Root_Dir          : Ada.Strings.Unbounded.Unbounded_String;
      --  Path on the host file system to be used as root directory for this FS

      Free_File_Handles : File_Handle_Ref;
      --  Linked list of file handles available to use

      Free_Dir_Handles : Directory_Handle_Ref;
      --  Likend list of directory handles available to use
   end record;

   function Get_Handle
     (FS : in out FS_Driver)
      return File_Handle_Ref;
   function Get_Handle
     (FS : in out FS_Driver)
      return Directory_Handle_Ref;
   --  Return an existing free handle or create one if none is available

   procedure Add_Free_Handle
     (FS     : in out FS_Driver;
      Handle : in out File_Handle_Ref)
     with Pre => Handle /= null,
     Post => Handle = null;
   procedure Add_Free_Handle
     (FS     : in out FS_Driver;
      Handle : in out Directory_Handle_Ref)
     with Pre => Handle /= null,
     Post => Handle = null;
   --  Add Handle to the list of available handles

   type File_Handle is tagged limited record
      FS   : FS_Driver_Ref;
      --  The filesystem that owns this handle

      Next : File_Handle_Ref;
      --  If this handle is used, this is undefined. Otherwise,
      --  this is the next free handle in the list (see
      --  Native_FS_Driver.Free_File_Handles).

      File : Byte_IO.File_Type;
   end record;

   type Directory_Data_Entry is record
      Kind : File_Kind;
      Name : Ada.Strings.Unbounded.Unbounded_String;
   end record;
   --  Set of information we handle for a directory entry

   package Directory_Data_Vectors is new Ada.Containers.Vectors
     (Positive, Directory_Data_Entry);

   type Directory_Handle is tagged limited record
      FS   : FS_Driver_Ref;
      --  The filesystem that owns this handle

      Next      : Directory_Handle_Ref;
      --  If this handle is used, this is undefined. Otherwise,
      --  this is the next free handle in the list (see
      --  Native_FS_Driver.Free_Dir_Handles).

      Full_Name : Ada.Strings.Unbounded.Unbounded_String;
      --  Absolute path for this directory

      Data : Directory_Data_Vectors.Vector;
      --  Vector of entries for this directory.
      --
      --  On one hand, HAL.Filesystem exposes an index-based API to access
      --  directory entries. On the other hand, Ada.Directories exposes a
      --  kind of single-linked list. What we do here is that when we open a
      --  directory, we immediately get all entries and build a vector out of
      --  it for convenient random access.
   end record;

end Bitmap.Filesystem;
