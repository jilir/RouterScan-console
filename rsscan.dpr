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
  BasicPairs: String;
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

  BasicPairs := 'admin'#9''#13#10+
    'admin'#9'admin'#13#10+
    'admin'#9'1234'#13#10+
    'admin'#9'password'#13#10+
    'Admin'#9'Admin'#13#10+
    ''#9'admin'#13#10+
    'root'#9''#13#10+
    'root'#9'admin'#13#10+
    'root'#9'root'#13#10+
    'root'#9'public'#13#10+
    'admin'#9'nimda'#13#10+
    'admin'#9'adminadmin'#13#10+
    'admin'#9'gfhjkm'#13#10+
    'admin'#9'airlive'#13#10+
    'airlive'#9'airlive'#13#10+
    ''#9'root'#13#10+
    ''#9''#13#10+
    'support'#9''#13#10+
    'support'#9'support'#13#10+
    'super'#9'super'#13#10+
    'super'#9'APR@xuniL'#13#10+
    'super'#9'zxcvbnm,./'#13#10+
    'admin'#9'onlime'#13#10+
    'super'#9'asong'#13#10+
    'admin'#9'mts'#13#10+
    'mts'#9'mts'#13#10+
    'telecomadmin'#9'admintelecom'#13#10+
    'mgts'#9'mtsoao'#13#10+
    'admin'#9'Uq-4GIt3M'#13#10+
    ''#9'aDm1n$TR8r'#13#10+
    'kyivstar'#9'kyivstar'#13#10+
    'admin'#9'0508780503'#13#10+
    'telekom'#9'telekom'#13#10+
    'superadmin'#9'Is$uper@dmin'#13#10+
    'admin'#9'dPZb4GJTu9'#13#10+
    'admin'#9'2w4f6n8k'#13#10+
    'admin'#9'szt'#13#10+
    'admin'#9'radmin'#13#10+
    'admin'#9'RTadmin1979'#13#10+
    'engineer'#9'amplifier'#13#10+
    'admin'#9'newit43'#13#10+
    'superadmin'#9'Jkbvgbflf2014'#13#10+
    'admin'#9'Jkbvgbflf2014'#13#10+
    'admin'#9'1'#13#10+
    'admin'#9'123'#13#10+
    'admin'#9'0000'#13#10+
    'admin'#9'00000000'#13#10+
    'admin'#9'12345'#13#10+
    'admin'#9'123456'#13#10+
    'admin'#9'1234567'#13#10+
    'admin'#9'12345678'#13#10+
    'admin'#9'123456789'#13#10+
    'admin'#9'1234567890'#13#10+
    'admin'#9'qwerty'#13#10+
    'admin'#9'beeline'#13#10+
    'admin'#9'beeline2013'#13#10+
    'admin'#9'iyeh'#13#10+
    'admin'#9'ghbdtn'#13#10+
    'admin'#9'admin225'#13#10+
    'admin'#9'rombik1'#13#10+
    'admin'#9'ho4uku6at'#13#10+
    'admin'#9'juklop'#13#10+
    'admin'#9'free'#13#10+
    'admin'#9'inet'#13#10+
    'admin'#9'internet'#13#10+
    'admin'#9'asus'#13#10+
    'admin'#9'root'#13#10+
    'admin'#9'ADMIN'#13#10+
    'admin'#9'adsl'#13#10+
    'admin'#9'adslroot'#13#10+
    'admin'#9'adsladmin'#13#10+
    'admin'#9'Ferum'#13#10+
    'admin'#9'Ferrum'#13#10+
    'admin'#9'FERUM'#13#10+
    'admin'#9'FERRUM'#13#10+
    'admin'#9'Kendalf9'#13#10+
    'admin'#9'263297'#13#10+
    'admin'#9'590152'#13#10+
    'admin'#9'21232'#13#10+
    'admin'#9'adn8pzszk'#13#10+
    'admin'#9'amvqnekk'#13#10+
    'admin'#9'biyshs9eq'#13#10+
    'admin'#9'e2b81d_1'#13#10+
    'admin'#9'Dkdk8e89'#13#10+
    'admin'#9'flvbyctnb'#13#10+
    'admin'#9'qweasdOP'#13#10+
    'admin'#9'EbS2P8'#13#10+
    'admin'#9'FhF8WS'#13#10+
    'admin'#9'ZmqVfo'#13#10+
    'admin'#9'ZmqVfo1'#13#10+
    'admin'#9'ZmqVfo2'#13#10+
    'admin'#9'ZmqVfo3'#13#10+
    'admin'#9'ZmqVfo4'#13#10+
    'admin'#9'ZmqVfoVPN'#13#10+
    'admin'#9'ZmqVfoSIP'#13#10+
    'admin'#9'ZmqVfoN1'#13#10+
    'admin'#9'ZmqVfoN2'#13#10+
    'admin'#9'ZmqVfoN3'#13#10+
    'admin'#9'ZmqVfoN4'#13#10+
    'admin'#9'9f4r5r79//'#13#10+
    'admin'#9'airocon'#13#10+
    'admin'#9'zyxel'#13#10+
    'adsl'#9'realtek'#13#10+
    'osteam'#9'5up'#13#10+
    'root'#9'toor'#13#10+
    'ZXDSL'#9'ZXDSL'#13#10+
    ''#9'support'#13#10+
    ''#9'Cisco'#13#10+
    'Cisco'#9'Cisco'#13#10+
    ''#9'cisco'#13#10+
    'cisco'#9'cisco'#13#10+
    'admin'#9'default'#13#10+
    'admin'#9'cisco'#13#10+
    'admin'#9'changeme'#13#10+
    ''#9'c'#13#10+
    ''#9'cc'#13#10+
    ''#9'Cisco router'#13#10+
    ''#9'letmein'#13#10+
    ''#9'_Cisco'#13#10+
    'enable'#9'cisco'#13#10+
    'pnadmin'#9'pnadmin'#13#10+
    'root'#9'attack'#13#10+
    'root'#9'Cisco'#13#10+
    'user'#9''#13#10+
    'user'#9'user'#13#10+
    'admin'#9'123321Aa'#13#10+
    ''#9'user';
  if not SetParam(stPairsBasic, PChar(BasicPairs)) then begin
    Writeln('Failed to load Basic Authentication pairs');
    Exit;
  end;
  if not SetParam(stPairsDigest, PChar(BasicPairs)) then begin
    Writeln('Failed to load Digest Authentication pairs');
    Exit;
  end;
  if not SetParam(stPairsForm, PChar(BasicPairs)) then begin
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
