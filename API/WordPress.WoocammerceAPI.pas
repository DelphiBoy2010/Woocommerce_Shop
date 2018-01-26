unit WordPress.WoocammerceAPI;

interface
uses
  Rest.Types, Data.DB;

type
  TWoocommerceAPI = class(TObject)
  type
    TSectionType = (stProduct, stCategory);
    TActionType = (atListAll);
  private const
    C_WP_API_URL = '/wp-json/wc/v2';
  private
    FStoreURL: string;
    FConsumerKey: string;
    FConsumerSecret: string;

    function GetAPI_URL: string;
    /// <summary>
    ///   Result as JSON
    /// </summary>
    function GetData(aSection: TSectionType; aAction: TActionType; var aDataSet: TDataSet): string;
    function GetSectionURL(aSection: TSectionType): string;
    function GetRequestType(aAction: TActionType): TRESTRequestMethod;
  protected
    FCategory: string;
  public
    constructor Create(aStoreURL, aConsumerKey, aConsumerSecret: string);
    destructor Destroy; override;

    /// <summary>
    ///   return categories list as JSON
    /// </summary>
    function GetCategoriesList(aDataSet: TDataSet): string;
    property API_Url: string read GetAPI_Url;
  end;

var
  WooAPI: TWoocommerceAPI = nil;

implementation

uses
  System.SysUtils {$IFDEF UseLogger}, LoggerManager{$ENDIF}
  , REST.Authenticator.OAuth, Rest.Client, REST.Response.Adapter;

{ TWoocommerceAPI }

constructor TWoocommerceAPI.Create(aStoreURL, aConsumerKey, aConsumerSecret: string);
begin
  {$IFDEF UseLogger}
  FCategory := ClassName;
  Logger.AddCategory(FCategory);
  {$ENDIF}
  FStoreURL := aStoreURL;
  FConsumerKey := aConsumerKey;
  FConsumerSecret := aConsumerSecret;
end;

destructor TWoocommerceAPI.Destroy;
begin

  inherited;
end;

function TWoocommerceAPI.GetAPI_URL: string;
begin
  Result := FStoreURL + C_WP_API_URL;
end;

function TWoocommerceAPI.GetCategoriesList(aDataSet: TDataSet): string;
begin
  Result := GetData(stCategory, atListAll, aDataSet);
end;

function TWoocommerceAPI.GetData(aSection: TSectionType;
  aAction: TActionType; var aDataSet: TDataSet): string;
const
  MethodName = 'GetData';
var
  OAuth1_WooCammerce: TOAuth1Authenticator;
  EndPoint: string;
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  RESTResponseDataSetAdapter: TRESTResponseDataSetAdapter;
begin
  Result := '';
  OAuth1_WooCammerce := TOAuth1Authenticator.Create(nil);
  RESTClient := TRESTClient.Create('');
  RESTRequest := TRESTRequest.Create(nil);
  RESTResponse := TRESTResponse.Create(nil);
  RESTResponseDataSetAdapter := TRESTResponseDataSetAdapter.Create(nil);
  try
    try
      EndPoint := GetAPI_URL + GetSectionURL(aSection);
      OAuth1_WooCammerce.ConsumerKey := FConsumerKey;
      OAuth1_WooCammerce.ConsumerSecret := FConsumerSecret;

      OAuth1_WooCammerce.AccessTokenEndpoint := EndPoint;
      OAuth1_WooCammerce.AuthenticationEndpoint := EndPoint;
      OAuth1_WooCammerce.RequestTokenEndpoint := EndPoint;


      OAuth1_WooCammerce.AccessToken := '';
      OAuth1_WooCammerce.AccessTokenSecret := '';
      OAuth1_WooCammerce.RequestToken := '';
      OAuth1_WooCammerce.RequestTokenSecret := '';
      OAuth1_WooCammerce.VerifierPIN := '';

      /// step #1, get request-token
      RESTClient.BaseURL := OAuth1_WooCammerce.RequestTokenEndpoint;
      RESTClient.Authenticator := OAuth1_WooCammerce;

      RESTRequest.Client := RESTClient;
      RESTRequest.Response := RESTResponse;
      RESTRequest.Method := GetRequestType(aAction);

      RESTRequest.Execute;

      if not RESTResponse.JSONText.IsEmpty then
      begin
        RESTResponseDataSetAdapter.Dataset := aDataSet;
        RESTResponseDataSetAdapter.Response := RESTResponse;
        RESTResponseDataSetAdapter.Active := True;
      end;

      //RESTResponseDataSetAdapter.Active := True;
      //ClientDataSet.Open;
    except
      on E: Exception do
      begin
        {$IFDEF UseLogger}
        Logger.DoLog(ltError, ClassName + '.' + MethodName, FCategory, [E.Message]);
        {$ENDIF}
      end;
    end;
  finally
    OAuth1_WooCammerce.Free;
    RESTResponseDataSetAdapter.Free;
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
  end;
end;

function TWoocommerceAPI.GetRequestType(
  aAction: TActionType): TRESTRequestMethod;
begin
  case aAction of
    atListAll: Result := rmGET;
  end;
end;

function TWoocommerceAPI.GetSectionURL(aSection: TSectionType): string;
begin
  case aSection of
    stProduct: Result := '/products';
    stCategory: Result := '/products/categories';
  end;
end;

end.
