program WoocommerceAPI_Sample;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm in 'MainForm.pas' {Form3},
  WordPress.WoocammerceAPI in 'API\WordPress.WoocammerceAPI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
