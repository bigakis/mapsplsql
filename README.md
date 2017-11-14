# MapPL/SQL
A very simple interface to google maps.
I will use it to add coordinates to customers based on their address.

To use it:
```
declare
  mapItem map$types_pkg.tMapItem;
begin
  mapItem := maps$api_pkg.getMapItem('100 Somestreet,ZIP');
  maps$types_pkg.printMapItem(mapItem);
end;
```
