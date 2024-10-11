unit coord;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TCoord = record
    x, y: integer;
  end;

  TCoordF = record
    x, y: double;
  end;

  TCoordDynArray = array of TCoord;

const
  InvalidCoord: TCoord = (x: -1; y: -1);

  function IsInvalidCoord(c: TCoord): boolean;

implementation

function IsInvalidCoord(c: TCoord): boolean;
begin
  if (c.x = InvalidCoord.x) and (c.y = InvalidCoord.y) then
    result := true
  else
    result := false;
end;

end.

