
[code]
Const
  //窗口移动
  WM_SYSCOMMAND = $0112;
  GWL_STYLE = (-16);
  ES_LEFT   =  0;
  ES_CENTER =  1;
  ES_RIGHT  =  2;
  
type 
 HDC=LongWord;
 HFont=LongWord;
  
function SetWindowLong(Wnd: HWnd; Index: Integer; NewLong: Longint): Longint; external 'SetWindowLongA@user32.dll stdcall';
function GetWindowLong(Wnd: HWnd; NewLong: Longint): Longint; external 'GetWindowLongA@user32.dll stdcall';

function CreateRoundRectRgn(p1, p2, p3, p4, p5, p6: Integer): THandle; external 'CreateRoundRectRgn@gdi32 stdcall';
function SetWindowRgn(hWnd: HWND; hRgn: THandle; bRedraw: Boolean): Integer; external 'SetWindowRgn@user32 stdcall';
function ReleaseCapture(): Longint; external 'ReleaseCapture@user32.dll stdcall';

procedure Misc_SetFormRoundRectRgn(aForm: TForm; edgeSize: integer);
var
  FormRegion:LongWord;
begin
  FormRegion:=CreateRoundRectRgn(0,0,aForm.Width,aForm.Height,edgeSize-6,edgeSize-6);
  SetWindowRgn(aForm.Handle,FormRegion,True);
end;

//窗口移动
procedure _Misc_WizardFormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  SendMessage(WizardForm.Handle, WM_SYSCOMMAND, $F012, 0);
end;

procedure Misc_SetForm_Dragable(aForm: TForm);
var 
  MainLabel:TLabel;
begin
  //5.5版的WizardForm，的确是取消了OnMouseDown事件， 但庆幸是的TLabel还支持这个事件，所以我们在初始化时，WizardForm顶部放一个透明的TLabel控件即可。
  MainLabel := TLabel.Create(aForm);
  MainLabel.Parent := aForm;
  MainLabel.AutoSize := False;
  MainLabel.Left := 0;
  MainLabel.Top := 0;
  MainLabel.Width := aForm.Width;
  MainLabel.Height := 50;
  MainLabel.Caption := '';
  MainLabel.Transparent := True;
  MainLabel.OnMouseDown := @_Misc_WizardFormMouseDown;
end;

procedure Misc_SetTEdit_TextCenter(edit: TEdit);
begin
  SetWindowLong(edit.Handle, GWL_STYLE, GetWindowLong(edit.Handle, GWL_STYLE) or ES_CENTER);
end;

procedure Misc_SetTEdit_TextVCenter(edit:TEdit);
begin
end;
//procedure Misc_SetTEdit_TextVCenter(edit:TEdit);
//var
// DC: HDC;
// SaveFont: HFont;
// Sin: Integer;
// SysMetrics, Metrics: TTextMetric;
// Rct: TRect;
//begin 
// DC := GetDC(0);
// GetTextMetrics(DC, SysMetrics);
// SaveFont := SelectObject(DC, Font.Handle);
// GetTextMetrics(DC, Metrics);
// SelectObject(DC, SaveFont);
// ReleaseDC(0, DC);
// with edit do begin
//   if Ctl3D then Sin := 8 else Sin := 6;
//   Rct := edit.ClientRect;
//   Sin := Height - Metrics.tmHeight - Sin;
//   Rct.Top := Sin div 2;
//   SendMessage(Handle, EM_SETRECT, 0, Integer(@Rct));
// end
//end;


function Misc_FomatByteText(const I: Longint):string;
var
  X: Extended;
begin
  if I > 1073741824 then 
  begin 
    X := (I*1.0 / 1073741824) * 100; { * 100 to include 2 decimals }
    //if Frac(X) > 0 then
    //  X := Int(X) + 1;  { always round up }
    X := X / 100;
    Result := Format('%.2f GB', [X]);
	Exit;
  end;
  
  if I > 1048576 then 
  begin
    X := (I*1.0 / 1048576) * 10; { * 10 to include a decimal }
    //if Frac(X) > 0 then
    //  X := Int(X) + 1;  { always round up }
    X := X / 10;
    Result := Format('%.1f MB', [X]);
	Exit;
  end;
  
  if I > 1024 then 
  begin
    X := I*1.0 / 1024;
    //if Frac(X) > 0 then
    //  X := Int(X) + 1;  { always round up }
    Result := Format('%.0f KB', [X]);
	Exit;
  end;
  Result := Format('%d B', [I]);
end;


