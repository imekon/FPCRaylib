unit animations;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, raylib, animator, ball;

type

  { TBlockAnimation }

  TBlockAnimation = class(TAnimateData)
  private
    m_block: TBlock;
  public
    constructor Create(w: integer; block: TBlock);
    procedure Draw(anim: TAnimate); override;
  end;

implementation

{ TBlockAnimation }

constructor TBlockAnimation.Create(w: integer; block: TBlock);
begin
  inherited Create(w);
  m_block := block;
end;

procedure TBlockAnimation.Draw(anim: TAnimate);
begin
  m_block.Draw;
end;

end.

