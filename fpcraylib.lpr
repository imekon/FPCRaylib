program fpcraylib;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, RayLib, dbgpanel, animator, coord, game, ball;

var
  Application: TFPCGame;

begin
  Application := TFPCGame.Create(nil);
  Application.Title := AppTitle;
  Application.Run;
  Application.Free;
end.

