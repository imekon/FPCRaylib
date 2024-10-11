unit game;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, CustApp, Raylib, dbgpanel, animator, ball;

type
  { TFPCGame }
  TFPCGame = class(TCustomApplication)
  private
    m_ball: TBall;
    m_block: TBlock;
    m_debugPanel: TDebugPanel;
    m_animator: TAnimator;
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

  const AppTitle = 'Free Pascal Raylib';

implementation

{ TFPCGame }

constructor TFPCGame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  SetTraceLogLevel(LOG_DEBUG);

  InitWindow(800, 600, AppTitle); // for window settings, look at example - window flags

  SetTargetFPS(60); // Set our game to run at 60 frames-per-second

  m_ball := TBall.Create;
  m_block := TBlock.Create;

  m_debugPanel := TDebugPanel.Create;
  m_debugPanel.AddTitle('Debug Panel');
  m_debugPanel.AddButton('Animate Ease In', nil);

  m_animator := TAnimator.Create;
end;

procedure TFPCGame.DoRun;
var
  delta: double;

begin

  while (not WindowShouldClose) do // Detect window close button or ESC key
  begin
    // Update your variables here
    delta := GetFrameTime;

    m_ball.Update(delta);
    m_block.Update(delta);
    m_debugPanel.Update;
    m_animator.Update(delta);

    // Draw
    BeginDrawing();
      ClearBackground(RAYWHITE);
      DrawText('FPC Game window', 190, 200, 20, LIGHTGRAY);
      m_block.Draw;
      m_ball.Draw;
      m_debugPanel.Draw;
    EndDrawing();
  end;

  // Stop program loop
  Terminate;
end;

destructor TFPCGame.Destroy;
begin
  // De-Initialization
  CloseWindow(); // Close window and OpenGL context

  // Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
  TraceLog(LOG_INFO, 'your first window is close and destroy');

  m_ball.Free;
  m_animator.Free;
  m_debugPanel.Free;

  inherited Destroy;
end;



end.

