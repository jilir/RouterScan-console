// Demo console application using LibRouter
// Copyright (C) Stas'M Corp. 2014-2017

// Project home page:
// http://stascorp.com/load/1-1-0-56

program demo;

{$IFDEF FPC}
  {$MODE DelphiUnicode}
{$ENDIF}

{$APPTYPE CONSOLE}

uses
{$IFDEF UNIX}
  cthreads,
  cmem,
{$ENDIF}
{$IFnDEF FPC}
  Windows,
{$ENDIF}
  SysUtils,
  LibRouter;

type
  TIPv4 = record case Boolean of
    False: (dw: LongWord);
    True: (b: Array[0..3] of Byte);
  end;

procedure SetTableDataW(Row: DWord; Name, Value: PChar); stdcall;
begin
  if Row <> 123 then
    Exit;
  Writeln(String(Name), ': ', String(Value));
  flush(output);
end;

var
  mCount: DWord;
  I: Integer;
  IPint: LongWord;
  Module: TModuleDesc;
  Pairs: String;
  IP: TIPv4;
  Port: Word;
  hRouter: Pointer;
begin
  if not Initialize() then begin
    Writeln(StdErr, 'librouter Initialize failed');
    Exit;
  end;

  if not GetModuleCount(mCount) then begin
    Writeln(StdErr, 'librouter GetModuleCount failed');
    Exit;
  end;
  for I := 0 to mCount - 1 do begin
    if not GetModuleInfo(I, @Module) then begin
      Writeln(StdErr, 'librouter GetModuleInfo failed');
      Exit;
    end;
    //Write(StdErr, 'Module name: ', String(Module.Name), ' (');
    if Module.Enabled then
      //Writeln(StdErr, 'enabled)')
    else
      //Writeln(StdErr, 'disabled)');
  end;

  SetParam(stProxyType, 0); // don't use proxy
  SetParam(stUserAgent, PChar('Mozilla/5.0 (Windows NT 5.1; rv:9.0.1) Gecko/20100101 Firefox/9.0.1'));
  SetParam(stUseCustomPage, Pointer(False));
  SetParam(stDualAuthCheck, Pointer(False));

  Pairs := 'admin'#9'admin'#13#10+
           'admin'#9'password'#13#10+
           'admin'#9'123321Aa'#13#10+
           'admin'#9'1234'#13#10;
  if not SetParam(stPairsBasic, PChar(Pairs)) then begin
	Writeln(Pairs);
    Writeln('Failed to load Basic Authentication pairs');
    Exit;
  end;
  if not SetParam(stPairsDigest, PChar(Pairs)) then begin
    Writeln('Failed to load Digest Authentication pairs');
    Exit;
  end;
  if not SetParam(stPairsForm, PChar(Pairs)) then begin
    Writeln('Failed to load Form Authentication pairs');
    Exit;
  end;
  Writeln('Pairs updated');

  if not SetParam(stSetTableDataCallback, @SetTableDataW) then begin
    Writeln(StdErr, 'Failed to set callback procedure');
    Exit;
  end;
  while not eof do begin
    Read(IPInt);
    Readln(Port);
    if not PrepareRouter(123, IPInt, Port, hRouter) then begin
      Writeln(StdErr, 'PrepareRouter failed');
      Exit;
    end;
    if not ScanRouter(hRouter) then begin
      Writeln('ScanRouter failed');
      Exit;
    end;
    if not FreeRouter(hRouter) then begin
      Writeln('FreeRouter failed');
      Exit;
    end;
    Writeln('$$$end');
    flush(output);
  end;
end.
