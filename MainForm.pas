unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Edit, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, IPPeerClient, REST.Client, REST.Authenticator.Basic,
  Data.Bind.Components, Data.Bind.ObjectScope, Datasnap.DBClient;

type
  TForm3 = class(TForm)
    Label1: TLabel;
    Panel1: TPanel;
    edtSiteUrl: TEdit;
    Layout1: TLayout;
    Label2: TLabel;
    Layout2: TLayout;
    edtConsumerSecret: TEdit;
    Label3: TLabel;
    Layout3: TLayout;
    edtConsumerKey: TEdit;
    Label4: TLabel;
    Layout4: TLayout;
    btnLoadCategories: TButton;
    Panel2: TPanel;
    ListView1: TListView;
    RESTClient1: TRESTClient;
    HTTPBasicAuthenticator1: THTTPBasicAuthenticator;
    qryCategory: TClientDataSet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoadCategoriesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.fmx}

uses WordPress.WoocammerceAPI;

procedure TForm3.btnLoadCategoriesClick(Sender: TObject);
var
  LItem: TListViewItem;
  ResponseData: string;
begin
  ListView1.Items.Clear;
  WooAPI.GetCategoriesList(qryCategory);
  //if not ResponseData.IsEmpty then
  begin
    try
      qryCategory.Close;
      qryCategory.Open;
      while not qryCategory.Eof do
      begin
        LItem := ListView1.Items.Add;
        LItem.Data['ID'] := qryCategory.FieldByName('id').AsInteger;
        LItem.Text := qryCategory.FieldByName('name').AsString;
        LItem.Detail := '';
        LItem.ButtonText := 'لیست محصولات';

        qryCategory.Next;
      end;
    finally

    end;
  end;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  WooAPI :=  TWoocommerceAPI.Create(edtSiteUrl.Text, edtConsumerKey.Text, edtConsumerSecret.Text);
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  FreeAndNil(WooAPI);
end;

end.
