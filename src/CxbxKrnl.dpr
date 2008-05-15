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
library CxbxKrnl;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Windows,
  SysUtils,
  Dialogs,
  Classes,
  uEmuShared in 'uEmuShared.pas',
  uEmu in 'uEmu.pas',
  uEnums in 'uEnums.pas',
  uLog in 'uLog.pas',
  uLogConsole in 'uLogConsole.pas' {frm_LogConsole},
  uEmuFS in 'uEmuFS.pas',
  uXbe in 'uXbe.pas',
  uConsts in 'uConsts.pas',
  uMutex in 'uMutex.pas',
  uKernelThunk in 'uKernelThunk.pas',
  uTime in 'uTime.pas',
  uBitsOps in 'uBitsOps.pas';

{$R *.res}   

exports
  CxbxKrnlInit,
  CxbxKrnlNoFunc,
  SetXbePath name '?SetXbePath@EmuShared@@QAEXPBD@Z',
  CxbxKrnl_KernelThunkTable;

(*  Exports EmuVerifyVersion name '_EmuVerifyVersion@4';
  Exports EmuPanic name '_EmuPanic@0';
  Exports ;
  Exports EmuCleanup;
  Exports EmuCleanThread name '_EmuCleanThread@0';
  { TODO : name need to be set }
  (*Exports Init; // name must be "void EmuShared::Init (void)
  //  Exports KernelThunkTable;*)

procedure DllMain(Reason: Integer);
begin
  if Reason = DLL_PROCESS_ATTACH then
    Init
  else
    if Reason = DLL_PROCESS_DETACH then
      Cleanup;
end;

begin
  CreateLogs(ltKernel);
  DllProc := DllMain;
  DllProc(DLL_PROCESS_ATTACH);
end.