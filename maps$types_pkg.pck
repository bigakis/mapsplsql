create or replace package maps$types_pkg is

  -- Author  : BIGAKIS
  -- Created : 14/11/2017 4:07:07 μμ
  -- Purpose : 
type tMapItem is record (
  place_id nvarchar2(100),
  route    nvarchar2(100),
  no       nvarchar2(100),
  locality nvarchar2(100),
  admlvl3  nvarchar2(100),
  country  nvarchar2(100),
  zip      nvarchar2(100),
  fmtaddr  nvarchar2(1000),
  loctype  nvarchar2(100),
  lng      number,
  lat      number
);

function StringToMapItem(pString in clob) return tMapItem;

procedure printMapItem(fMapItem in tMapItem);

end maps$types_pkg;
/
create or replace package body maps$types_pkg is

function correctString(pString in nvarchar2) return nvarchar2 is
begin
  if (instr(pString, '\u') <= 0) then
    return replace(pString, '"', '');
  end if;
  return unistr(replace(replace(pString, '\u', '\'), '"', ''));
end;

function StringToMapItem(pString in clob) return tMapItem is
  fRet   tMapItem;
  fAddr  json;
  fAddrC json_list;
  fVal   nvarchar2(1000);
begin
  fAddr  := json(json_list(json(pString).get('results')).get(1));
  fAddrC := json_list(fAddr.get('address_components'));
  for i in 1 .. fAddrC.count()
  loop
    fVal := correctString(json(fAddrC.get(i)).get('long_name').to_char());
    case json_list(json(fAddrC.get(i)).get('types')).get(1).to_char()
      when '"street_number"' then fRet.no       := fVal;
      when '"country"'       then fRet.country  := fVal;
      when '"route"'         then fRet.route    := fVal;
      when '"locality"'      then fRet.locality := fVal;
      when '"postal_code"'   then fRet.zip      := fVal;
      when '"administrative_area_level_3"'      then fRet.admlvl3 := fVal;
      else print(json_list(json(fAddrC.get(i)).get('types')).get(1).to_char());
    end case;
  end loop;
  fRet.place_id := correctString(fAddr.get('place_id').to_char());
  fRet.fmtaddr  := correctString(fAddr.get('formatted_address').to_char());
  fRet.loctype  := correctString(json(fAddr.get('geometry')).get('location_type').to_char());
  fRet.lng      := json(json(fAddr.get('geometry')).get('location')).get('lng').get_number();
  fRet.lat      := json(json(fAddr.get('geometry')).get('location')).get('lat').get_number();
  return fRet;
end;

procedure printMapItem(fMapItem in tMapItem) is
begin
  print('--------------------------------------------');
  print('Place ID : ' || fMapItem.place_id);
  print('Fmt Addr : ' || fMapItem.fmtaddr);
  print('Route    : ' || fMapItem.route);
  print('Street No: ' || fMapItem.no);
  print('Country  : ' || fMapItem.country);
  print('Locality : ' || fMapItem.locality);
  print('Adm Level: ' || fMapItem.admlvl3);
  print('ZIP      : ' || fMapItem.zip);
  print('Loc. Type: ' || fMapItem.loctype);
  print('Longitude: ' || fMapItem.lng);
  print('Latitude : ' || fMapItem.lat);
  print('--------------------------------------------');
end;

end maps$types_pkg;
/
