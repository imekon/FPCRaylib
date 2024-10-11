unit animator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, coord, raylib;

type
  TAnimateType = (ANIM_LINEAR, ANIM_EASEIN, ANIM_EASEOUT, ANIM_EASEINOUT, ANIM_FLIP, ANIM_SPIKE);

  TAnimate = class;

  { TAnimateData }

  TAnimateData = class
  protected
    m_what: integer;
  public
    constructor Create(w: integer); virtual;
    destructor Destroy; override;
    procedure Draw(anim: TAnimate); virtual; abstract;
    procedure Update(anim: TAnimate); virtual;

    property What: integer read m_what;
  end;

  { TAnimate }

  TAnimate = class
  protected
    m_running, m_finished: boolean;
    m_type: TAnimateType;
    m_data: TAnimateData;
    m_time: double;
    m_duration: double;
    procedure UpdateFactor(factor: double); virtual; abstract;
  public
    constructor Create(t: TAnimateType; d: TAnimateData; duration: double); virtual;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    procedure Draw;
    procedure Update(delta: double);

    property Running: boolean read m_running;
    property Finished: boolean read m_finished;
    property Data: TAnimateData read m_data;
  end;

  TAnimationList = specialize TFPGList<TAnimate>;

  { TAnimateValue }

  TAnimateValue = class(TAnimate)
  private
    m_start, m_finish, m_value: double;
  protected
    procedure UpdateFactor(factor: double); override;
  public
    constructor Create(t: TAnimateType; d: TAnimateData; duration: double); override;
    procedure Initialise(astart, finish: double);
  end;

  { TAnimateCoord }

  TAnimateCoord = class(TAnimate)
  private
    m_source, m_destination, m_where: TCoordF;
  protected
    procedure UpdateFactor(factor: double); override;
  public
    constructor Create(t: TAnimateType; d: TAnimateData; duration: double); override;
    procedure Initialise(s, d: TCoordF);
    procedure SetDestination(d: TCoordF);

    property Where: TCoordF read m_where;
  end;

  { TAnimateColour }

  TAnimateColour = class(TAnimate)
  private
    m_source, m_destination, m_where: TColor;
  protected
    procedure UpdateFactor(factor: double); override;
  public
    constructor Create(t: TAnimateType; d: TAnimateData; duration: double); override;
    procedure Initialise(s, d: TColor);

    property Where: TColor read m_where;
  end;

  { TAnimator }

  TAnimator = class
  private
    m_animations: TAnimationList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Update(delta: double);
    function AddAnimationCoord(t: TAnimateType; data: TAnimateData; source, dest: TCoordF; dur: double): TAnimate;
    function AddAnimationColour(t: TAnimateType; data: TAnimateData; source, dest: TColor; dur: double): TAnimate;
    procedure Draw;
    procedure Purge;

    property Animations: TAnimationList read m_animations;
  end;

  function Lerp(start, finish, where: double): double;
  function EaseIn(t: double): double;
  function EaseOut(t: double): double;
  function EaseInOut(t: double): double;
  function Spike(t: double): double;
  function Flip(t: double): double;

implementation

function Lerp(start, finish, where: double): double;
begin
  result := (finish - start) * where + start;
end;

function EaseIn(t: double): double;
begin
  result := sqr(t);
end;

function EaseOut(t: double): double;
begin
  result := Flip(sqr(Flip(t)))
end;

function EaseInOut(t: double): double;
begin
  result := Lerp(EaseIn(t), EaseOut(t), t);
end;

function Spike(t: double): double;
begin
  if t < 0.5 then
  begin
    result := EaseIn(t / 0.5);
    exit;
  end;

  result := EaseIn(Flip(t) / 0.5);
end;

function Flip(t: double): double;
begin
  result := 1.0 - t;
end;

{ TAnimateData }

constructor TAnimateData.Create(w: integer);
begin
  m_what := w;
end;

destructor TAnimateData.Destroy;
begin
  inherited Destroy;
end;

procedure TAnimateData.Update(anim: TAnimate);
begin
  //
end;

{ TAnimate }

constructor TAnimate.Create(t: TAnimateType; d: TAnimateData; duration: double);
begin
  m_running := false;
  m_finished := false;
  m_type := t;
  m_data := d;
  m_time := 0.0;
  m_duration := duration;
end;

destructor TAnimate.Destroy;
begin
  if Assigned(m_data) then m_data.Free;
  inherited Destroy;
end;

procedure TAnimate.Start;
begin
  m_running := true;
  m_finished := false;
  m_time := 0;
end;

procedure TAnimate.Stop;
begin
  m_running := false;
end;

procedure TAnimate.Draw;
begin
  if Assigned(m_data) then m_data.Draw(self);
end;

procedure TAnimate.Update(delta: double);
var
  factor: double;

begin
  if m_running then
  begin
    if m_time < m_duration then
      m_time := m_time + delta
    else
    begin
      m_running := false;
      m_finished := true;
    end;

    case m_type of
      ANIM_LINEAR: factor := m_time / m_duration;
      ANIM_EASEIN: factor := EaseIn(m_time / m_duration);
      ANIM_EASEOUT: factor := EaseOut(m_time / m_duration);
      ANIM_EASEINOUT: factor := EaseInOut(m_time / m_duration);
      ANIM_FLIP: factor := Flip(m_time / m_duration);
      ANIM_SPIKE: factor := Spike(m_time / m_duration);
    end;

    UpdateFactor(factor);

    if Assigned(m_data) then m_data.Update(self);
  end;
end;

{ TAnimateValue }

constructor TAnimateValue.Create(t: TAnimateType; d: TAnimateData; duration: double);
begin
  inherited Create(t, d, duration);
end;

procedure TAnimateValue.Initialise(astart, finish: double);
begin
  m_start := astart;
  m_finish := finish;
  m_value := m_start;
end;

procedure TAnimateValue.UpdateFactor(factor: double);
begin
  m_value := lerp(m_start, m_finish, factor);
end;

{ TAnimateCoord }

constructor TAnimateCoord.Create(t: TAnimateType; d: TAnimateData; duration: double);
begin
  inherited Create(t, d, duration);
end;

procedure TAnimateCoord.Initialise(s, d: TCoordF);
begin
  m_source := s;
  m_destination := d;
  m_where := s;
end;

procedure TAnimateCoord.SetDestination(d: TCoordF);
begin
  m_destination := d;
end;

procedure TAnimateCoord.UpdateFactor(factor: double);
begin
  m_where.x := lerp(m_source.x, m_destination.x, factor);
  m_where.y := lerp(m_source.y, m_destination.y, factor);
end;

{ TAnimateColour }

procedure TAnimateColour.UpdateFactor(factor: double);
begin
  m_where.r := round(lerp(m_source.r, m_destination.r, factor));
  m_where.g := round(lerp(m_source.g, m_destination.g, factor));
  m_where.b := round(lerp(m_source.b, m_destination.b, factor));
  m_where.a := round(lerp(m_source.a, m_destination.a, factor));
end;

constructor TAnimateColour.Create(t: TAnimateType; d: TAnimateData;
  duration: double);
begin
  inherited Create(t, d, duration);
end;

procedure TAnimateColour.Initialise(s, d: TColor);
begin
  m_source := s;
  m_destination := d;
end;

{ TAnimator }

constructor TAnimator.Create;
begin
  m_animations := TAnimationList.Create;
end;

destructor TAnimator.Destroy;
begin
  m_animations.Free;
  inherited Destroy;
end;

procedure TAnimator.Update(delta: double);
var
  anim: TAnimate;

begin
  for anim in m_animations do
    anim.Update(delta);
end;

function TAnimator.AddAnimationCoord(t: TAnimateType; data: TAnimateData;
  source, dest: TCoordF; dur: double): TAnimate;
var
  animation: TAnimateCoord;

begin
  animation := TAnimateCoord.Create(t, data, dur);
  animation.Initialise(source, dest);

  m_animations.Add(animation);
  result := animation;
end;

function TAnimator.AddAnimationColour(t: TAnimateType; data: TAnimateData;
  source, dest: TColor; dur: double): TAnimate;
var
  animation: TAnimateColour;

begin
  animation := TAnimateColour.Create(t, data, dur);
  animation.Initialise(source, dest);
  m_animations.Add(animation);
  result := animation;
end;

procedure TAnimator.Draw;
var
  anim: TAnimate;

begin
  for anim in m_animations do
    anim.Draw;
end;

procedure TAnimator.Purge;
var
  animate: TAnimate;
  purged: TAnimationList;

begin
  purged := TAnimationList.Create;
  for animate in m_animations do
  begin
    if animate.Finished then purged.Add(animate);
  end;

  for animate in purged do
  begin
    m_animations.Remove(animate);
    animate.Free;
  end;

  purged.Free;
end;

end.

