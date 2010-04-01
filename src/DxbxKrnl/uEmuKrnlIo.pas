(*
    This file is part of Dxbx - a XBox emulator written in Delphi (ported over from cxbx)
    Copyright (C) 2007 Shadow_tj and other members of the development team.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)
unit uEmuKrnlIo;

{$INCLUDE Dxbx.inc}

interface

uses
  // Delphi
  SysUtils,
  // Jedi Win32API
  JwaWinType,
  JwaWinBase,
  JwaWinNT,
  JwaNative,
  JwaNTStatus,
  // OpenXDK
  XboxKrnl,
  // Dxbx
  uLog,
  uEmuFS,
  uEmuFile,
  uEmuXapi,
  uEmuKrnl,
  uDxbxUtils,
  uDxbxKrnl,
  uDxbxKrnlUtils;

// TODO -oDXBX: Translate all other IRP defines from ReactOS
const IRP_MJ_MAXIMUM_FUNCTION = $1B;

type IRP = packed record
    cType: CSHORT;
    Size: USHORT;
(*
    MdlAddress: P_MDL;
    Flags: ULONG;
    union begin
      MasterIrp: P_IRP;
      IrpCount: LongInt; // volatile
      SystemBuffer: PVOID;
    end;
    ThreadListEntry: LIST_ENTRY;
    IoStatus: IO_STATUS_BLOCK;
    RequestorMode: KPROCESSOR_MODE;
    PendingReturned: BOOLEAN;
    StackCount: CHAR;
    CurrentLocation: CHAR;
    Cancel: BOOLEAN;
    CancelIrql: KIRQL;
    ApcEnvironment: CCHAR;
    AllocationFlags: UCHAR;
    UserIosb: PIO_STATUS_BLOCK;
    UserEvent: PKEVENT;

    // TODO -oDXBX: Translate all below
    union begin
      struct begin
        PIO_APC_ROUTINE  UserApcRoutine;
        PVOID  UserApcContext;
       end; AsynchronousParameters;
      LARGE_INTEGER  AllocationSize;
     end; Overlay;
    volatile PDRIVER_CANCEL  CancelRoutine;
    PVOID  UserBuffer;
    union begin
      struct begin
        _ANONYMOUS_UNION union begin
          KDEVICE_QUEUE_ENTRY  DeviceQueueEntry;
          _ANONYMOUS_STRUCT struct begin
              DriverContext: array [0..4-1] of PVOID;
           end; DUMMYSTRUCTNAME;
         end; DUMMYUNIONNAME;
        PETHREAD  Thread;
        PCHAR  AuxiliaryBuffer;
        _ANONYMOUS_STRUCT struct begin
          LIST_ENTRY  ListEntry;
          _ANONYMOUS_UNION union begin
            struct _IO_STACK_LOCATION  *CurrentStackLocation;
            ULONG  PacketType;
           end; DUMMYUNIONNAME;
         end; DUMMYSTRUCTNAME;
        struct _FILE_OBJECT  *OriginalFileObject;
       end; Overlay;
      KAPC  Apc;
      PVOID  CompletionKey;
     end; Tail;
*)
  end;
  PIRP = ^IRP;

  PDRIVER_EXTENSION = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  PFAST_IO_DISPATCH = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  PDRIVER_INITIALIZE = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  PDRIVER_STARTIO = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  PDRIVER_UNLOAD = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  PDRIVER_DISPATCH = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  PIO_TIMER_ROUTINE = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  PVPB = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  DEVICE_TYPE = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  KDEVICE_QUEUE = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  KEVENT = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS
  PKEVENT = ^KEVENT;
  PDEVOBJ_EXTENSION = UNKNOWN; // TODO -oDXBX: Lookup in ReactOS

  PDEVICE_OBJECT = ^DEVICE_OBJECT; // forward;
  PPDEVICE_OBJECT = ^PDEVICE_OBJECT;

// I/O Timer Object
{type} IO_TIMER = packed record
// Source: ReactOS  Branch:Dxbx  Translator:PatrickvL  Done:100
    Type_: USHORT;
    TimerEnabled: USHORT;
    IoTimerList: LIST_ENTRY;
    TimerRoutine: PIO_TIMER_ROUTINE;
    Context: PVOID;
    DeviceObject: PDEVICE_OBJECT;
  end;
  PIO_TIMER = ^IO_TIMER;

{type} DRIVER_OBJECT = packed record
// Source: ReactOS  Branch:Dxbx  Translator:PatrickvL  Done:100
    Type_: CSHORT;
    Size: CSHORT;
    DeviceObject: PDEVICE_OBJECT;
    Flags: ULONG;
    DriverStart: PVOID;
    DriverSize: ULONG;
    DriverSection: PVOID;
    DriverExtension: PDRIVER_EXTENSION;
    DriverName: UNICODE_STRING;
    HardwareDatabase: PUNICODE_STRING;
    FastIoDispatch: PFAST_IO_DISPATCH;
    DriverInit: PDRIVER_INITIALIZE;
    DriverStartIo: PDRIVER_STARTIO;
    DriverUnload: PDRIVER_UNLOAD;
    MajorFunction: array [0..IRP_MJ_MAXIMUM_FUNCTION] of PDRIVER_DISPATCH;
  end;
  PDRIVER_OBJECT = ^DRIVER_OBJECT;

{type} DEVICE_OBJECT = packed record
// Source: XBMC / ReactOS  Branch:Dxbx  Translator:PatrickvL  Done:100
    Type_: CSHORT;
    Size: USHORT;
    ReferenceCount: LONG;
    DriverObject: PDRIVER_OBJECT;
    // Source: ReactOS
    NextDevice: PDEVICE_OBJECT;
    AttachedDevice: PDEVICE_OBJECT;
    CurrentIrp: PIRP;
    Timer: PIO_TIMER;
    Flags: ULONG;
    Characteristics: ULONG;
    Vpb: PVPB; // volatile
    DeviceExtension: PVOID;
    DeviceType: DEVICE_TYPE;
    StackSize: CCHAR;
//    union {
    ListEntry: LIST_ENTRY;
//      Wcb: WAIT_CONTEXT_BLOCK;
//    } Queue; // Dxbx TODO
    AlignmentRequirement: ULONG;
    DeviceQueue: KDEVICE_QUEUE;
    Dpc: KDPC;
    ActiveThreadCount: ULONG;
    SecurityDescriptor: PSECURITY_DESCRIPTOR;
    DeviceLock: KEVENT;
    SectorSize: USHORT;
    Spare1: USHORT;
    DeviceObjectExtension: PDEVOBJ_EXTENSION;
    Reserved: PVOID;
  end;

type FILE_OBJECT = packed record
// Source: XBMC  Branch:Dxbx  Translator:PatrickvL  Done:100
    Type_: CSHORT;
    Size: CSHORT;
    DeviceObject: PDEVICE_OBJECT;
   // ...
  end;
  PFILE_OBJECT = ^FILE_OBJECT;

type SHARE_ACCESS = packed record
// Source: ReactOS  Branch:Dxbx  Translator:PatrickvL  Done:100
    OpenCount: ULONG;
    Readers: ULONG;
    Writers: ULONG;
    Deleters: ULONG;
    SharedRead: ULONG;
    SharedWrite: ULONG;
    SharedDelete: ULONG;
  end;
  PSHARE_ACCESS = ^SHARE_ACCESS;

var {064}xboxkrnl_IoCompletionObjectType: POBJECT_TYPE = NULL;
// Source:?  Branch:Dxbx  Translator:PatrickvL  Done:0

var {070}xboxkrnl_IoDeviceObjectType: POBJECT_TYPE = NULL;
// Source:?  Branch:Dxbx  Translator:PatrickvL  Done:0

var {071}xboxkrnl_IoFileObjectType: POBJECT_TYPE = NULL;
// Source:?  Branch:Dxbx  Translator:PatrickvL  Done:0

function {059} xboxkrnl_IoAllocateIrp(
  StackSize: CCHAR;
  ChargeQuota: LONGBOOL
  ): PIRP; stdcall;
function {060} xboxkrnl_IoBuildAsynchronousFsdRequest(
  MajorFunction: ULONG;
  DeviceObject: PDEVICE_OBJECT;
  Buffer: PVOID; // OUT OPTIONAL
  Length: ULONG; // OPTIONAL,
  StartingOffset: PLARGE_INTEGER; // OPTIONAL
  IoStatusBlock: PIO_STATUS_BLOCK // OPTIONAL
  ): PIRP; stdcall;
function {061} xboxkrnl_IoBuildDeviceIoControlRequest(
  IoControlCode: ULONG;
  DeviceObject: PDEVICE_OBJECT;
  InputBuffer: PVOID; // OPTIONAL,
  InputBufferLength: ULONG;
  OutputBuffer: PVOID; // OUT OPTIONAL
  OutputBufferLength: ULONG;
  InternalDeviceIoControl: BOOLEAN;
  Event: PKEVENT;
  IoStatusBlock: PIO_STATUS_BLOCK // OUT
  ): PIRP; stdcall;
function {062} xboxkrnl_IoBuildSynchronousFsdRequest(
  MajorFunction: ULONG;
  DeviceObject: PDEVICE_OBJECT;
  Buffer: PVOID; // OUT OPTIONAL,
  Length: ULONG; // OPTIONAL,
  StartingOffset: PLARGE_INTEGER; // OPTIONAL,
  Event: PKEVENT;
  IoStatusBlock: PIO_STATUS_BLOCK // OUT
  ): PIRP; stdcall;
function {063} xboxkrnl_IoCheckShareAccess(
  DesiredAccess: ACCESS_MASK;
  DesiredShareAccess: ULONG;
  FileObject: PFILE_OBJECT; // OUT
  ShareAccess: PSHARE_ACCESS; // OUT
  Update: BOOLEAN
  ): NTSTATUS; stdcall;
function {065} xboxkrnl_IoCreateDevice(
  DriverObject: PDRIVER_OBJECT;
  DeviceExtensionSize: ULONG;
  DeviceName: PUNICODE_STRING;
  DeviceType: DEVICE_TYPE;
  DeviceCharacteristics: ULONG;
  Exclusive: BOOLEAN;
  DeviceObject: PPDEVICE_OBJECT // out
  ): NTSTATUS; stdcall;
function {066} xboxkrnl_IoCreateFile(
  FileHandle: PHANDLE; // out
  DesiredAccess: ACCESS_MASK;
  ObjectAttributes: POBJECT_ATTRIBUTES;
  IoStatusBlock: PIO_STATUS_BLOCK; // out
  AllocationSize: PLARGE_INTEGER;
  FileAttributes: ULONG;
  ShareAccess: ULONG;
  Disposition: ULONG;
  CreateOptions: ULONG;
  Options: ULONG
  ): NTSTATUS; stdcall;
function xboxkrnl_IoCreateSymbolicLink(
  SymbolicLinkName: PSTRING;
  DeviceName: PSTRING
  ): NTSTATUS; stdcall;
function xboxkrnl_IoDeleteDevice(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoDeleteSymbolicLink(
  SymbolicLinkName: PSTRING
  ): NTSTATUS; stdcall;
function xboxkrnl_IoFreeIrp(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoInitializeIrp(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoInvalidDeviceRequest(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoQueryFileInformation(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoQueryVolumeInformation(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoQueueThreadIrp(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoRemoveShareAccess(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoSetIoCompletion(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoSetShareAccess(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoStartNextPacket(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoStartNextPacketByKey(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoStartPacket(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoSynchronousDeviceIoControlRequest(
  IoControlCode: ULONG ;
  DeviceObject: PDEVICE_OBJECT;
  InputBuffer: PVOID ; // OPTIONAL
  InputBufferLength: ULONG;
  OutputBuffer: PVOID; // OPTIONAL
  OutputBufferLength: ULONG;
  unknown_use_zero: PDWORD; // OPTIONAL
  InternalDeviceIoControl: BOOLEAN
  ): NTSTATUS; stdcall;
function xboxkrnl_IoSynchronousFsdRequest(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IofCallDriver(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IofCompleteRequest(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoDismountVolume(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function xboxkrnl_IoDismountVolumeByName(
  VolumeName: PSTRING
  ): NTSTATUS; stdcall;
function xboxkrnl_IoMarkIrpMustComplete(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE

implementation

function {059} xboxkrnl_IoAllocateIrp(
  StackSize: CCHAR;
  ChargeQuota: LONGBOOL // TODO -oDXBX: Should this be a WordBool??
  ): PIRP; stdcall;
// Source:ReactOS  Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Unimplemented('IoAllocateIrp');
  Result := nil;
  EmuSwapFS(fsXbox);
end;

function {060} xboxkrnl_IoBuildAsynchronousFsdRequest(
  MajorFunction: ULONG;
  DeviceObject: PDEVICE_OBJECT;
  Buffer: PVOID; // OUT OPTIONAL
  Length: ULONG; // OPTIONAL,
  StartingOffset: PLARGE_INTEGER; // OPTIONAL
  IoStatusBlock: PIO_STATUS_BLOCK // OPTIONAL
  ): PIRP; stdcall;
// Source:ReactOS  Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Unimplemented('IoBuildAsynchronousFsdRequest');
  Result := nil;
  EmuSwapFS(fsXbox);
end;

function {061} xboxkrnl_IoBuildDeviceIoControlRequest(
  IoControlCode: ULONG;
  DeviceObject: PDEVICE_OBJECT;
  InputBuffer: PVOID; // OPTIONAL,
  InputBufferLength: ULONG;
  OutputBuffer: PVOID; // OUT OPTIONAL
  OutputBufferLength: ULONG;
  InternalDeviceIoControl: BOOLEAN;
  Event: PKEVENT;
  IoStatusBlock: PIO_STATUS_BLOCK // OUT
  ): PIRP; stdcall;
// Source:ReactOS  Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Unimplemented('IoBuildDeviceIoControlRequest');
  Result := nil;
  EmuSwapFS(fsXbox);
end;

function {062} xboxkrnl_IoBuildSynchronousFsdRequest(
  MajorFunction: ULONG;
  DeviceObject: PDEVICE_OBJECT;
  Buffer: PVOID; // OUT OPTIONAL,
  Length: ULONG; // OPTIONAL,
  StartingOffset: PLARGE_INTEGER; // OPTIONAL,
  Event: PKEVENT;
  IoStatusBlock: PIO_STATUS_BLOCK // OUT
  ): PIRP; stdcall;
// Source:ReactOS  Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Unimplemented('IoBuildSynchronousFsdRequest');
  Result := nil;
  EmuSwapFS(fsXbox);
end;

function {063} xboxkrnl_IoCheckShareAccess(
  DesiredAccess: ACCESS_MASK;
  DesiredShareAccess: ULONG;
  FileObject: PFILE_OBJECT; // OUT
  ShareAccess: PSHARE_ACCESS; // OUT
  Update: BOOLEAN
  ): NTSTATUS; stdcall;
// Source:ReactOS  Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoCheckShareAccess');
  EmuSwapFS(fsXbox);
end;

// IoCreateDevice
//
// Allocates memory for and intializes a device object for use for
// a driver.
//
// Parameters
//    DriverObject
//       Driver object passed by IO Manager when the driver was loaded.
//
//    DeviceExtensionSize
//       Number of bytes for the device extension.
//
//    DeviceName
//       Unicode name of device.
//
//    DeviceType
//       Device type of the new device.
//
//    DeviceCharacteristics
//       Bit mask of device characteristics.
//
//    Exclusive
//       TRUE if only one thread can access the device at a time.
//
//    DeviceObject
//       On successful return this parameter is filled by pointer to
//       allocated device object.

function {065} xboxkrnl_IoCreateDevice(
  DriverObject: PDRIVER_OBJECT;
  DeviceExtensionSize: ULONG;
  DeviceName: PUNICODE_STRING;
  DeviceType: DEVICE_TYPE;
  DeviceCharacteristics: ULONG;
  Exclusive: BOOLEAN;
  DeviceObject: PPDEVICE_OBJECT // out
  ): NTSTATUS; stdcall;
// Source:ReactOS  Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoCreateDevice');
  EmuSwapFS(fsXbox);
end;

function {066} xboxkrnl_IoCreateFile
(
  FileHandle: PHANDLE; // out
  DesiredAccess: ACCESS_MASK;
  ObjectAttributes: POBJECT_ATTRIBUTES;
  IoStatusBlock: PIO_STATUS_BLOCK; // out
  AllocationSize: PLARGE_INTEGER;
  FileAttributes: ULONG;
  ShareAccess: ULONG;
  Disposition: ULONG;
  CreateOptions: ULONG;
  Options: ULONG
): NTSTATUS; stdcall;
// Source:Cxbx  Branch:shogun  Revision:0.8.1-Pre2  Translator:PatrickvL  Done:100
begin
  EmuSwapFS(fsWindows);

{$IFDEF DEBUG}
  DbgPrintf('EmuKrnl : IoCreateFile' +
     #13#10'(' +
     #13#10'   FileHandle          : 0x%.08X' +
     #13#10'   DesiredAccess       : 0x%.08X' +
     #13#10'   ObjectAttributes    : 0x%.08X (%s)' +
     #13#10'   IoStatusBlock       : 0x%.08X' +
     #13#10'   AllocationSize      : 0x%.08X' +
     #13#10'   FileAttributes      : 0x%.08X' +
     #13#10'   ShareAccess         : 0x%.08X' +
     #13#10'   Disposition         : 0x%.08X' +
     #13#10'   CreateOptions       : 0x%.08X' +
     #13#10'   Options             : 0x%.08X' +
     #13#10');',
     [FileHandle, DesiredAccess, ObjectAttributes, PSTRING_Buffer(ObjectAttributes.ObjectName),
      IoStatusBlock, AllocationSize, FileAttributes, ShareAccess, Disposition, CreateOptions, Options]);
{$ENDIF}

  Result := STATUS_SUCCESS;

  // TODO -oCXBX: Try redirecting to NtCreateFile if this function ever is run into
  CxbxKrnlCleanup('IoCreateFile not implemented');

  EmuSwapFS(fsXbox);
end;

// IoCreateSymbolicLink:
// Creates a symbolic link in the object namespace.
// NtCreateSymbolicLinkObject is much harder to use than this simple
// function, so just use this one.
//
// Differences from NT: Uses ANSI_STRING instead of UNICODE_STRING.
function xboxkrnl_IoCreateSymbolicLink
(
  SymbolicLinkName: PSTRING;
  DeviceName: PSTRING
): NTSTATUS; stdcall;
// Branch:martin  Revision:39  Translator:PatrickvL  Done:100
begin
  EmuSwapFS(fsWindows);

{$IFDEF DEBUG}
  DbgPrintf('EmuKrnl : IoCreateSymbolicLink' +
     #13#10'(' +
     #13#10'   SymbolicLinkName    : 0x%.08X (%s)' +
     #13#10'   DeviceName          : 0x%.08X (%s)' +
     #13#10');',
     [SymbolicLinkName, PSTRING_Buffer(SymbolicLinkName),
     DeviceName, PSTRING_Buffer(DeviceName)]);
{$ENDIF}

  // TODO -oCXBX: Actually um...implement this function
  Result := STATUS_OBJECT_NAME_COLLISION;

  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoDeleteDevice(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoDeleteDevice');
  EmuSwapFS(fsXbox);
end;

// IoDeleteSymbolicLink:
// Creates a symbolic link in the object namespace.  Deleting symbolic links
// through the Nt* functions is a pain, so use this instead.
//
// Differences from NT: Uses ANSI_STRING instead of UNICODE_STRING.
function xboxkrnl_IoDeleteSymbolicLink
(
  SymbolicLinkName: PSTRING
): NTSTATUS; stdcall;
// Branch:martin  Revision:39  Translator:PatrickvL  Done:100
begin
  EmuSwapFS(fsWindows);

{$IFDEF DEBUG}
  DbgPrintf('EmuKrnl : IoDeleteSymbolicLink' +
      #13#10'(' +
      #13#10'   SymbolicLinkName    : 0x%.08X (%s)' +
      #13#10');',
      [SymbolicLinkName, PSTRING_Buffer(SymbolicLinkName)]);
{$ENDIF}

  // TODO -oCXBX: Actually um...implement this function
  Result := STATUS_OBJECT_NAME_NOT_FOUND;

  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoFreeIrp(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoFreeIrp');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoInitializeIrp(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoInitializeIrp');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoInvalidDeviceRequest(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoInvalidDeviceRequest');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoQueryFileInformation(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoQueryFileInformation');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoQueryVolumeInformation(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoQueryVolumeInformation');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoQueueThreadIrp(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoQueueThreadIrp');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoRemoveShareAccess(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoRemoveShareAccess');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoSetIoCompletion(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoSetIoCompletion');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoSetShareAccess(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoSetShareAccess');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoStartNextPacket(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoStartNextPacket');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoStartNextPacketByKey(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoStartNextPacketByKey');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoStartPacket(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoStartPacket');
  EmuSwapFS(fsXbox);
end;

// IoSynchronousDeviceIoControlRequest:
// NICE.  Makes kernel driver stuff sooooo much easier.  This does a
// blocking IOCTL on the specified device.
//
// New to the XBOX.
function xboxkrnl_IoSynchronousDeviceIoControlRequest(
  IoControlCode: ULONG ;
  DeviceObject: PDEVICE_OBJECT;
  InputBuffer: PVOID ; // OPTIONAL
  InputBufferLength: ULONG;
  OutputBuffer: PVOID; // OPTIONAL
  OutputBufferLength: ULONG;
  unknown_use_zero: PDWORD; // OPTIONAL
  InternalDeviceIoControl: BOOLEAN
  ): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoSynchronousDeviceIoControlRequest');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoSynchronousFsdRequest(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoSynchronousFsdRequest');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IofCallDriver(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IofCallDriver');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IofCompleteRequest(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IofCompleteRequest');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoDismountVolume(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoDismountVolume');
  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoDismountVolumeByName
(
  VolumeName: PSTRING
): NTSTATUS; stdcall;
// Source:OpenXDK  Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  EmuSwapFS(fsWindows);
{$IFDEF DEBUG}
  DbgPrintf('EmuKrnl : IoDismountVolumeByName' +
      #13#10'(' +
      #13#10'   VolumeName        : 0x%.08X (%s)' +
      #13#10');',
      [VolumeName, PSTRING_Buffer(VolumeName)]);
{$ENDIF}

  // TODO -oCXBX: Anything?
  Result := STATUS_SUCCESS;

  EmuSwapFS(fsXbox);
end;

function xboxkrnl_IoMarkIrpMustComplete(): NTSTATUS; stdcall;
// Branch:Dxbx  Translator:PatrickvL  Done:0
begin
  EmuSwapFS(fsWindows);
  Result := Unimplemented('IoMarkIrpMustComplete');
  EmuSwapFS(fsXbox);
end;

end.
