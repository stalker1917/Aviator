unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation,Math, FMX.Edit
{$IFDEF ANDROID}
   ,System.IOUtils;
 {$ELSE}
 ;
 {$ENDIF}
const
  EtalonWidth = 800;
  EtalonHeight = 400;
    PaintRect : TRectF  =
    (
      Left: 0;
      Top: 0;
      Right: 10;
      Bottom: 10;
    );
  HighLabels = 7;
type


  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    StyleBook1: TStyleBook;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    //procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
   // procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
   //   Shift: TShiftState; X, Y: Single);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
   // procedure Button4Click(Sender: TObject);
    procedure SetButtonPosition;
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas;
      const [Ref] ARect: TRectF);
    procedure ClearRect(X1,Y1,X2,Y2:Integer);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    AutoBet : Double;
    Bank  : Integer;
    Coins : Integer;
    Bet : Integer;
    Coifficient : Double;
    CoefLabels : Array [0..HighLabels] of TLabel;
    function GetCoins:Integer;
    function OneRound:Boolean;
    function CoefToColor(C:Double):LongWord;
    procedure DrawAircraft;
    procedure Cls;
    procedure AddLine;


  end;
//Procedure Redraw(y,c:integer;pod:TPodatel; mh:boolean);

var
  Form1: TForm1;

var
  karti:array[1..37] of TBitmap;   {Рисунки карт}
  BMPAircraft : TBitMap;
  BMPFon  : TBitMap;
  BDFon   : TBitmapData;
  bopod:boolean;
  GoodOpen : Boolean=False;
  report:text;
  AircraftX : Integer=0;
  AircraftY : Integer=0;
  YesAircraft : Boolean = False;


implementation

{$R *.fmx}

Function EtalonToX(X:Integer):Integer;
begin
  Result:=Round(X*Form1.ClientWidth/EtalonWidth);
end;

Function EtalonToY(Y:Integer):Integer;
begin
  Result:=Round(Y*Form1.ClientHeight/EtalonHeight);
end;

Function XToEtalon(X:Single):Integer;
begin
  Result:=Round(X*EtalonWidth/Form1.ClientWidth);
end;

Function YToEtalon(Y:Single):Integer;
begin
  Result:=Round(Y*EtalonHeight/Form1.ClientHeight);
end;

procedure WriteToLog(S:String);
begin
  WriteLn(report,S);
  Flush(report);
end;



{Загрузка ресурсов}
function GetColor(var BD: TBitmapData;Component :integer; x:Integer;y:Integer):Byte;
var A,i:LongWord;
begin
  A:= BD.GetPixel(x,y);
  for i := 1 to Component do
    A:= A div $100;
  result := A mod $100;
end;

function GetRed(var BD: TBitmapData; x:Integer;y:Integer):Byte;
begin
  result :=GetColor(BD,2,x,y);
end;

function GetGreen(var BD: TBitmapData; x:Integer;y:Integer):Byte;
begin
  result :=GetColor(BD,1,x,y);
end;

function GetBlue(var BD: TBitmapData; x:Integer;y:Integer):Byte;
begin
  result :=GetColor(BD,0,x,y);
end;

procedure TForm1.Cls;
var i,j:Integer;
begin
 BMPFon.Map(TMapAccess.ReadWrite,BDFon);
 for i := 0 to BMPFon.Width-1 do
   for j := 0 to BMPFon.Height-1 do
     BDFon.SetPixel(i,j,TAlphaColors.Seagreen);
 BMPFon.Unmap(BDFon);
end;

procedure TForm1.AddLine;
var i,j:Integer;
A:Integer;
begin
  if AirCraftX+60>BMPFon.Width-1 then exit;
  BMPFon.Map(TMapAccess.ReadWrite,BDFon);
  A :=150-AirCraftY;
  if A<0  then  A:=0;

  for j := A to 170 do
    BDFon.SetPixel(AirCraftX+60,j,TAlphaColors.Tan);
  BMPFon.Unmap(BDFon);
end;

procedure TForm1.FormCreate(Sender: TObject);
var fil:file; i,j,x,y:integer; t:byte;
BD,BDBuf: TBitmapData;
bl:Boolean;
BMPAircraftBuf : TBitMap;
A : LongWord;

begin
  //BMPAircraftbuf := TBitMap.Create;
  Bank := 1000;
  BMPAircraft := TBitMap.Create;
   {$IFDEF ANDROID}
   BMPAircraft.LoadFromFile(TPath.GetDocumentsPath+'/pngegg.png');
 {$ELSE}
  BMPAircraft.LoadFromFile('pngegg.png');
 {$ENDIF}
 //reset(fil,
  //BMPAircraft.Height := BMPAircraftbuf.Height;
  //BMPAircraft.Width :=  BMPAircraftbuf.Width;
  {$IFDEF ANDROID}
 assignfile(report,TPath.GetPublicPath+'/report.txt');
 button2.Visible := False;
 {$ELSE}
 assignfile(report,'report.txt');
 {$ENDIF}
 ReWrite(report);
 WriteTolog('Sussesfull start');
 bl:=BMPAircraft.Map(TMapAccess.ReadWrite,BD);
// BMPAircraftBuf.Map(TMapAccess.ReadWrite,BDbuf);
 for i := 0 to BMPAircraft.Width-1 do
   for j := 0 to BMPAircraft.Height-1 do
     if (GetRed(BD,i,j)>200) and (GetBlue(BD,i,j)>200) and (GetGreen(BD,i,j)<50) then
        BD.SetPixel(i,j,0);      //Добавление прозрачности
     // begin
       // A:=BDbuf.GetPixel(i,j);
       // BD.SetPixel(i,j,A);
     // end;
 BMPAircraft.Unmap(BD);   //Иначе изменения не применяются!
 BMPFon := TBitmap.Create;
 BMPFon.Height := EtalonHeight-100;
 BMPFon.Width := 600;//EtalonWidth;
 for I := 0 to HighLabels do
   begin
     CoefLabels[i] := TLabel.Create(Self);
     CoefLabels[i].Parent := Self;
     CoefLabels[i].StyledSettings :=  [];
     CoefLabels[i].FontColor := TAlphaColors.Black;
     CoefLabels[i].AutoSize := True;
     CoefLabels[i].Font.Size := 20;
     CoefLabels[i].Visible := True;
     CoefLabels[i].Name:=CoefLabels[i].ClassName + IntToStr(10+i);
     CoefLabels[i].Text := '   ';
   end;


 //bl:=BMPFon.Map(TMapAccess.ReadWrite,BDFon);

// {$IFDEF ANDROID}
 //assignfile(fil,TPath.GetDocumentsPath+'/durak2.ini');
// {$ELSE}
 // assignfile(fil,'durak2.ini');
 //{$ENDIF}
 //reset(fil,8);
// blockread(fil,int,23);
 //NewInt:=Int;
 //for I := 1 to 23 do  NewInt[i]:=Int[i];

 //closefile(fil);
 //assignfile(report,'report.txt');
 //rewrite(report);
 GoodOpen := True;
 SetButtonPosition;
 WriteTolog('Sussesfull Create form');
// Label1.StyledSettings := [];
// Label1.TextSettings.FontColor := TAlphaColors.Black;
 //Label2.StyledSettings :=[];
 //Label1.TextSettings.Font.Size := 12;
 Cls;
 Invalidate;
end;


procedure TForm1.SetButtonPosition;
var
  I: Integer;
begin
//Вернуть позиционирование

  Button1.Position.X := EtalonToX(655);
  Button1.Position.Y := EtalonToY(280);
  Button2.Position.X := EtalonToX(655);
  Button2.Position.Y := EtalonToY(332);

  Label1.Position.X := EtalonToX(608);
  Label1.Position.Y := EtalonToY(24);
  Label2.Position.X := EtalonToX(608);
  Label2.Position.Y := EtalonToY(54);
  Label3.Position.X := EtalonToX(720);
  Label3.Position.Y := EtalonToY(24);
  Label4.Position.X := EtalonToX(720);
  Label4.Position.Y := EtalonToY(145);
  Label5.Position.X := EtalonToX(672);
  Label5.Position.Y := EtalonToY(184);
  Edit1.Position.X := EtalonToX(720);
  Edit1.Position.Y := EtalonToY(54);
  Edit2.Position.X := EtalonToX(720);
  Edit2.Position.Y := EtalonToY(84);
  CheckBox1.Position.X := EtalonToX(608);
  CheckBox1.Position.Y := EtalonToY(84);
  for I := 0 to HighLabels do
    begin
      CoefLabels[i].Position.X := EtalonToX(50+70*i);
      CoefLabels[i].Position.Y := 24;
    end;
  //Label3.Position.X := EtalonToX(280);
  //Label3.Position.Y := EtalonToY(144);
 //}
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin

    // i :=Random(1000);
    //Label1.Caption := IntToStr(i);
    if OneRound then
      begin
        Label4.Text := 'Улетел!';
        Coifficient := 0;
        Timer1.Enabled := False;
        Button1.Text := 'Поставить';
        //YesAircraft := False;
        Checkbox1.Enabled := True;
        Edit2.ReadOnly := False;
      end
   else
     begin
       //Coifficient := Coifficient*1.01;
       Coins := GetCoins;
       Label4.Text := IntToStr(Coins);
       Label5.Text := FloatToStrF(Coifficient,ffGeneral,3,4);
       if (CheckBox1.isChecked) and (Coifficient>=AutoBet) then  Button1Click(Sender);
     end;
  Invalidate;
end;

procedure TForm1.Button1Click(Sender: TObject);  {Сдать карты}
begin
   if Timer1.Enabled  then
     begin
       Bank := Bank+GetCoins;
       Bet := 0;
       Button1.Text := 'Поставить';
       Label4.Text := '0';
       while not OneRound do;
       Label5.Text := FloatToStrF(Coifficient,ffGeneral,3,4);
       //YesAircraft:= False;
       Invalidate;
     end
   else
     begin
       Randomize;
       Bet := StrToInt(Edit1.Text);
       AutoBet :=  StrToFloat(Edit2.Text);
       if Bet>Bank then Bet := Bank;
       Bank := Bank-Bet;
       Coifficient := 1;
       Button1.Text := 'Вывести';
       YesAircraft:= True;
       AircraftX := 0;
       Cls;
     end;
  Checkbox1.Enabled := Timer1.Enabled;
  Edit2.ReadOnly := not Timer1.Enabled;
  Timer1.Enabled := not Timer1.Enabled;
  Label3.Text := IntToStr(Bank);

end;


procedure TForm1.Button2Click(Sender: TObject);
begin
 form1.Close;
end;



procedure TForm1.DrawAircraft;
var R1,R2 : TRectF;
begin
  r1.Top := 0;
  r1.Left := 0;
  r1.Width := 546;
  r1.Height := 330;
  r2.Top := EtalonToX(200-AircraftY);//Round(y*Form1.Height/(5*100));  //Преобразование координат вынести в функцию.
  r2.Left := EtalonToX(40+AircraftX); //Round(x*Form1.Height/(5*100));
  r2.Width :=EtalonToX(95);//Round(karti[b].Width*Form1.Height/(5*100));
  r2.Height := EtalonToY(73);//Round(karti[b].Height*Form1.Height/(5*100));
 // Canvas.DrawBitmap(karti[b],r1,r2,1,False);
 Canvas.DrawBitmap(BMPAircraft,r1,r2,1,False);
end;

procedure TForm1.FormPaint(Sender: TObject; Canvas: TCanvas;
  const [Ref] ARect: TRectF);

begin
Canvas.BeginScene;
ClearRect(0,100,600,EtalonHeight);
if YesAircraft then DrawAircraft;
//Label1.Repaint;
Canvas.EndScene;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  SetButtonPosition;
  Invalidate;//FormPaint(Sender,Canvas,PaintRect);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var fil:file of double;
i:Integer;
begin
 if GoodOpen then
   begin
     closefile(report);
     {$IFNDEF ANDROID}
     assignfile(fil,'Durak2.ini');
     rewrite(fil);
     //blockwrite(fil,Newint,23);  //Как extended не пишется!
     closefile(fil);
     {$ENDIF}
   end;
end;

procedure TForm1.ClearRect;
var fs,fs2:TRectF;
begin
 // Form1.Canvas.BeginScene;
  fs.Top:=EtalonToY(Y1);
  fs.Left:=EtalonToX(X1);
  fs.Right:=EtalonToX(X2);
  fs.Bottom:=EtalonToY(Y2);
  fs2.Top := 0;
  fs2.Left := 0;
  fs2.Width := Bmpfon.Width;
  fs2.Height := Bmpfon.Height;
  Canvas.DrawBitmap(BMPFon,fs2,fs,1,False);

 // Form1.Canvas.Fill.Color :=  TAlphaColorRec.Seagreen;
  //form1.Canvas.FillRect(fs,0,0,AllCorners,1);
 // Form1.Canvas.EndScene;
end;

function TForm1.CoefToColor;
begin
  if C>25 then result := TAlphaColors.Red
  else
    if C>5 then
      begin
        result :=  TAlphaColors.Red;
        result :=  result + Round(-ln(C/25)*158);
      end
    else
      begin
        result :=  TAlphaColors.Blue;
        result :=  result + Round(ln(C)*158)*$10000;
      end;
end;

function TForm1.OneRound: Boolean;
var i:Integer;
begin
  I:=Random(1000);
  if i<=10 then
    begin
      result:=True;  //Улетел
      YesAircraft := False;
      for I := HighLabels downto 1 do
        begin
          CoefLabels[i].Text :=  CoefLabels[i-1].Text;
          CoefLabels[i].FontColor :=  CoefLabels[i-1].FontColor;
        end;
      CoefLabels[0].Text := FloatToStrF(Coifficient,ffGeneral,3,4);//Label5.Text;
      CoefLabels[0].FontColor := CoefToColor(Coifficient);
    end
  else
    begin
      Coifficient := Coifficient*1.01;
      AircraftX := AircraftX+1;
      AircraftY := Trunc((Coifficient-1)*10);
      AddLine;
      result:=False;
    end;
end;

function TForm1.GetCoins:Integer;
  begin
    result := Trunc(Coifficient*Bet);
  end;





end.
