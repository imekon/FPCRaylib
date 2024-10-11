unit dbgpanel;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fgl, raylib;

const
  DBG_PANEL_LEFT = 10;
  DBG_PANEL_INDENT = 10;
  DBG_PANEL_TOP = 10;
  DBG_PANEL_WIDTH = 200;
  DBG_PANEL_FONT_SIZE = 20;
  DBG_PANEL_BUTTON_HEIGHT = 22;
  DBG_PANEL_HEIGHT = 24;

type

  { TDebugItem }

  TDebugItem = class
  protected
    m_line: integer;
    m_text: string;
  public
    constructor Create(line: integer; const text: string); virtual;
    procedure Draw; virtual; abstract;
    function IsHit(x, y: integer): boolean; virtual;
    procedure NotifyHandler; virtual;

    property Line: integer read m_line;
    property Text: string read m_text;
  end;

  TDebugItemList = specialize TFPGList<TDebugItem>;

  { TDebugButton }

  TDebugButton = class(TDebugItem)
  private
    m_notify: TNotifyEvent;
    m_enable: boolean;
  public
    constructor Create(l: integer; const t: string; notify: TNotifyEvent); virtual;
    procedure Draw; override;
    function IsHit(x, y: integer): boolean; override;
    procedure NotifyHandler; override;
    property Enable: boolean read m_enable write m_enable;
  end;

  { TTickedButton }

  TTickedButton = class(TDebugButton)
  private
    m_ticked: boolean;
  public
    constructor Create(l: integer; const t: string; notify: TNotifyEvent); override;
    procedure Draw; override;
    property Ticked: boolean read m_ticked write m_ticked;
  end;

  { TDebugTitle }

  TDebugTitle = class(TDebugItem)
  public
    constructor Create(l: integer; const t: string); override;
    procedure Draw; override;
  end;

  { TDebugPanel }

  TDebugPanel = class
  private
    m_items: TDebugItemList;
    m_line: integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddTitle(const text: string);
    function AddButton(const text: string; notify: TNotifyEvent): TDebugButton;
    function AddTickedButton(const text: string; notify: TNotifyEvent): TTickedButton;
    procedure Draw;
    procedure Update;
  end;

implementation

{ TDebugItem }

constructor TDebugItem.Create(line: integer; const text: string);
begin
  m_line := line;
  m_text := text;
end;

function TDebugItem.IsHit(x, y: integer): boolean;
begin
  result := false;
end;

procedure TDebugItem.NotifyHandler;
begin
  //
end;

{ TDebugButton }

constructor TDebugButton.Create(l: integer; const t: string;
  notify: TNotifyEvent);
begin
  inherited Create(l, t);
  m_notify := notify;
  m_enable := true;
end;

procedure TDebugButton.Draw;
begin
  DrawRectangle(DBG_PANEL_LEFT, DBG_PANEL_TOP + m_line * DBG_PANEL_HEIGHT, DBG_PANEL_WIDTH, DBG_PANEL_BUTTON_HEIGHT, LIGHTGRAY);
  if m_enable then
    DrawText(PChar(m_text), DBG_PANEL_LEFT + DBG_PANEL_INDENT, DBG_PANEL_TOP + m_line * DBG_PANEL_HEIGHT, DBG_PANEL_FONT_SIZE, BLACK)
  else
    DrawText(PChar(m_text), DBG_PANEL_LEFT + DBG_PANEL_INDENT, DBG_PANEL_TOP + m_line * DBG_PANEL_HEIGHT, DBG_PANEL_FONT_SIZE, GRAY)
end;

function TDebugButton.IsHit(x, y: integer): boolean;
begin
  if not m_enable then exit;

  if (x >= DBG_PANEL_LEFT) and (x < DBG_PANEL_WIDTH + DBG_PANEL_LEFT) and
    (y >= m_line * DBG_PANEL_HEIGHT + DBG_PANEL_TOP) and
    (y < (m_line + 1) * DBG_PANEL_HEIGHT + DBG_PANEL_TOP) then
  begin
    TraceLog(LOG_DEBUG, PChar('Button ' + m_text + ' is pressed'));
    result := true
  end
  else
    result := false;
end;

procedure TDebugButton.NotifyHandler;
begin
  if Assigned(m_notify) then
    m_notify(self);
end;

{ TTickedButton }

constructor TTickedButton.Create(l: integer; const t: string;
  notify: TNotifyEvent);
begin
  inherited Create(l, t, notify);
  m_ticked := false;
end;

procedure TTickedButton.Draw;
begin
  if m_ticked then
    DrawRectangle(DBG_PANEL_LEFT, DBG_PANEL_TOP + m_line * DBG_PANEL_HEIGHT, DBG_PANEL_WIDTH, DBG_PANEL_BUTTON_HEIGHT, RED)
  else
    DrawRectangle(DBG_PANEL_LEFT, DBG_PANEL_TOP + m_line * DBG_PANEL_HEIGHT, DBG_PANEL_WIDTH, DBG_PANEL_BUTTON_HEIGHT, LIGHTGRAY);

  DrawText(PChar(m_text), DBG_PANEL_LEFT + DBG_PANEL_INDENT, DBG_PANEL_TOP + m_line * DBG_PANEL_HEIGHT, DBG_PANEL_FONT_SIZE, BLACK);
end;

{ TDebugTitle }

constructor TDebugTitle.Create(l: integer; const t: string);
begin
  inherited Create(l, t);
end;

procedure TDebugTitle.Draw;
begin
  DrawRectangle(DBG_PANEL_LEFT, DBG_PANEL_TOP + m_line * DBG_PANEL_HEIGHT, DBG_PANEL_WIDTH, DBG_PANEL_BUTTON_HEIGHT, LIGHTGRAY);
  DrawText(PChar(m_text), DBG_PANEL_LEFT, DBG_PANEL_TOP + m_line * DBG_PANEL_HEIGHT, DBG_PANEL_FONT_SIZE, BLUE);
end;

{ TDebugPanel }

constructor TDebugPanel.Create;
begin
  m_items := TDebugItemList.Create;
  m_line := 0;
end;

destructor TDebugPanel.Destroy;
var
  item: TDebugItem;

begin
  for item in m_items do
    item.Free;

  m_items.Free;
  inherited Destroy;
end;

procedure TDebugPanel.AddTitle(const text: string);
var
  title: TDebugTitle;

begin
  title := TDebugTitle.Create(m_line, text);
  m_items.Add(title);
  inc(m_line);
end;

function TDebugPanel.AddButton(const text: string; notify: TNotifyEvent
  ): TDebugButton;
var
  button: TDebugButton;

begin
  button := TDebugButton.Create(m_line, text, notify);
  m_items.Add(button);
  inc(m_line);
  result := button;
end;

function TDebugPanel.AddTickedButton(const text: string; notify: TNotifyEvent
  ): TTickedButton;
var
  button: TTickedButton;

begin
  button := TTickedButton.Create(m_line, text, notify);
  m_items.Add(button);
  inc(m_line);
  result := button;
end;

procedure TDebugPanel.Draw;
var
  item: TDebugItem;

begin
  for item in m_items do
    item.Draw;
end;

procedure TDebugPanel.Update;
var
  x, y: integer;
  item: TDebugItem;

begin
  if IsMouseButtonPressed(MOUSE_LEFT_BUTTON) then
  begin
    x := GetMouseX();
    y := GetMouseY();

    for item in m_items do
    begin
      if item.IsHit(x, y) then
        item.NotifyHandler;
    end;
  end;
end;

end.

