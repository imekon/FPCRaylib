unit ball;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, raylib;

type

  { TThing }

  TThing = class
  protected
    m_x, m_y: integer;
  public
    constructor Create; virtual;
    procedure Update(delta: double); virtual; abstract;
    procedure Draw; virtual; abstract;

    property X: integer read m_x write m_x;
    property Y: integer read m_y write m_y;
  end;

  { TBlock }

  TBlock = class(TThing)
  public
    constructor Create; override;
    procedure Update(delta: double); override;
    procedure Draw; override;
  end;

  { TBall }

  TBall = class(TThing)
  private
    m_dx, m_dy: integer;
  public
    constructor Create; override;
    procedure Update(delta: double); override;
    procedure Draw; override;
  end;

implementation

{ TThing }

constructor TThing.Create;
begin
  m_x := 0;
  m_y := 0;
end;

{ TBlock }

constructor TBlock.Create;
begin
  inherited Create;
end;

procedure TBlock.Update(delta: double);
begin
  m_x := 100;
  m_y := 400;
end;

procedure TBlock.Draw;
begin
  DrawRectangle(m_x, m_y, 50, 30, PURPLE);
end;

{ TBall }

constructor TBall.Create;
begin
  m_x := 200;
  m_y := 300;
  m_dx := -4;
  m_dy := 4;
end;

procedure TBall.Update(delta: double);
begin
  m_x := m_x + m_dx;
  m_y := m_y + m_dy;

  if (m_x < 0) or (m_x > GetScreenWidth) then m_dx := -m_dx;
  if (m_y < 0) or (m_y > GetScreenHeight) then m_dy := -m_dy;
end;

procedure TBall.Draw;
begin
  DrawCircle(m_x, m_y, 10, BLUE);
end;

end.

