create or replace package maps$api_pkg is

  -- Author  : BIGAKIS
  -- Created : 14/11/2017 2:31:38 ìì
  -- Purpose : 

function makeRequest(pAddress in nvarchar2) return varchar2;

function getMapItem(pAddress in nvarchar2) return maps$types_pkg.tMapItem;

end maps$api_pkg;
/
create or replace package body maps$api_pkg is

v_BASE_URL constant varchar2(100) := 'https://maps.googleapis.com';

v_APIKEY   constant varchar2(100) := '<GOOGLE API KEY>';

function formatAddress(pAddress in nvarchar2) return nvarchar2 is
  fAddr nvarchar2(1000);
begin
  fAddr := upper(replace(pAddress, ' ', '+'));
  --fAddr := translate(fAddr, 'ÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÓÔÕÖ×ØÙ','ABGDEZHUIKLMJOPRSTYFX
  return fAddr;
end;

function makeRequest(pAddress in nvarchar2) return varchar2 is
  res clob;
begin
  apex_web_service.g_request_headers(1).name  := 'User-Agent';
  apex_web_service.g_request_headers(1).Value := 'GoogleGeoApiClientPython/2.4.5';
  apex_web_service.g_request_headers(2).name  := 'verify';
  apex_web_service.g_request_headers(2).Value := 'True';
  res := apex_web_service.make_rest_request(
    p_url         => v_BASE_URL || '/maps/api/geocode/json',
    p_http_method => 'GET',
    p_parm_name   => apex_util.string_to_table('address:key:language'),
    p_parm_value  => apex_util.string_to_table(formatAddress(pAddress) || ':' || v_APIKey || ':el'),
    p_wallet_path => 'file:/home/o11gdb/app/o11gdb/admin/zeus/wallet_maps',
    p_wallet_pwd  => 'walletPasswd123'
  );
  res := regexp_replace(res, '[^[:print:]]', '');
  return res;
end;

function getMapItem(pAddress in nvarchar2) return maps$types_pkg.tMapItem is
begin
  return maps$types_pkg.StringToMapItem(makeRequest(pAddress));
end;

end maps$api_pkg;
/
