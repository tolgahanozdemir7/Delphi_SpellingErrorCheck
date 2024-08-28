unit KendiNLPModelim;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, System.Net.HttpClient, System.JSON;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);

  private
    function AskLanguageTool(AText: string): string;
    procedure LoadFileContent;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function EscapeJsonString(const S: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    case S[i] of
      '\': Result := Result + '\\';
      '"': Result := Result + '\"';
      #8: Result := Result + '\b';
      #12: Result := Result + '\f';
      #10: Result := Result + '\n';
      #13: Result := Result + '\r';
      else Result := Result + S[i];
    end;
  end;
end;

function TForm1.AskLanguageTool(AText: string): string;
var
  _Client: THTTPClient;
  _PostData, sString: string;
  _JsonValue: TJsonValue;
  _Response: IHTTPResponse;
  _DataStream: TStringStream;
  _JSONObject: TJSONObject;
begin
  Result := '';

  // Metni JSON formatýna uygun hale getir
  _PostData := '{"text": "' + EscapeJsonString(AText) + '"}';

  _DataStream := TStringStream.Create(_PostData, TEncoding.UTF8);

  try
    _DataStream.Position := 0;
    _Client := THTTPClient.Create;
    try
      _Client.CustomHeaders['Content-Type'] := 'application/json';

      _Response := _Client.Post('http://127.0.0.1:5000/correct', _DataStream);

      if _Response.StatusCode = 200 then
      begin
        sString := _Response.ContentAsString;
        _JsonValue := TJSONObject.ParseJSONValue(sString);

        if Assigned(_JsonValue) and (_JsonValue is TJSONObject) then
        begin
          _JSONObject := _JsonValue as TJSONObject;
          Result := _JSONObject.GetValue<string>('corrected_text');
        end;
      end
      else
      begin
        raise Exception.Create('Hata: ' + IntToStr(_Response.StatusCode) + ' - ' + _Response.ContentAsString);
      end;
    finally
      _Client.Free;
    end;
  finally
    _DataStream.Free;
  end;
end;

procedure TForm1.LoadFileContent;
var
  FileContent: TStringList;
begin
  // Dosya seçim penceresini aç ve kullanýcýnýn bir dosya seçip seçmediðini kontrol et
  if OpenDialog1.Execute then
  begin
    FileContent := TStringList.Create;
    try
      FileContent.LoadFromFile(OpenDialog1.FileName);
      Memo1.Lines.Add(AskLanguageTool(FileContent.Text));
    finally
      FileContent.Free;
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Memo1.Clear;
  LoadFileContent;
end;

end.


