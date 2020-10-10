
[Code]

// HoverEvent.iss

type
	HoverEvent_OnHoverControlChanged = procedure (Control: TControl);
	
var
  LastMouse: TPoint;
  LastHoverControl: TControl;
  HoverChangeCallback:HoverEvent_OnHoverControlChanged;

type
  TTimerProc = procedure(H: LongWord; Msg: LongWord; IdEvent: LongWord; Time: LongWord);

function GetCursorPos(var lpPoint: TPoint): BOOL;
  external 'GetCursorPos@user32.dll stdcall';
function SetTimer(hWnd: longword; nIDEvent, uElapse: LongWord; lpTimerFunc: LongWord):
  LongWord; external 'SetTimer@user32.dll stdcall';
function ScreenToClient(hWnd: HWND; var lpPoint: TPoint): BOOL;
  external 'ScreenToClient@user32.dll stdcall';
function ClientToScreen(hWnd: HWND; var lpPoint: TPoint): BOOL;
  external 'ClientToScreen@user32.dll stdcall';
function WrapTimerProc(Callback: TTimerProc; ParamCount: Integer): LongWord;
  external 'wrapcallback@files:innocallback.dll stdcall';
 
function HoverEvent_FindControl(Parent: TWinControl; P: TPoint): TControl;
var
  Control: TControl;
  WinControl: TWinControl;
  I: Integer;
  P2: TPoint;
begin
  { Top-most controls are the last. We want to start with those. }
  for I := Parent.ControlCount - 1 downto 0 do
  begin
    Control := Parent.Controls[I];
    if Control.Visible and
       (Control.Left <= P.X) and (P.X < Control.Left + Control.Width) and
       (Control.Top <= P.Y) and (P.Y < Control.Top + Control.Height) then
    begin
      if Control is TWinControl then
      begin
        P2 := P;
        ClientToScreen(Parent.Handle, P2);
        WinControl := TWinControl(Control);
        ScreenToClient(WinControl.Handle, P2);
        Result := HoverEvent_FindControl(WinControl, P2);
        if Result <> nil then Exit;
      end;

      Result := Control;
      Exit;
    end;
  end;

  Result := nil;
end;

procedure HoverEvent_HoverTimerProc(H: LongWord; Msg: LongWord; IdEvent: LongWord; Time: LongWord);
var
  P: TPoint;
  Control: TControl; 
begin
  GetCursorPos(P);
  if P <> LastMouse then { just optimization }
  begin
    LastMouse := P;
    ScreenToClient(WizardForm.Handle, P);

    if (P.X < 0) or (P.Y < 0) or
       (P.X > WizardForm.ClientWidth) or (P.Y > WizardForm.ClientHeight) then
    begin
      Control := nil;
    end
      else
    begin
      Control := HoverEvent_FindControl(WizardForm, P);
    end;

    if Control <> LastHoverControl then
    begin
      HoverChangeCallback(Control);
      LastHoverControl := Control;
    end;
  end;
end;

procedure HoverEvent_Init(cb:HoverEvent_OnHoverControlChanged);
begin
	HoverChangeCallback := cb;
	SetTimer(0, 0, 50, WrapTimerProc(@HoverEvent_HoverTimerProc, 4));
end;