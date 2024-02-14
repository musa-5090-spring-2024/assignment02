# Import shapefile through ogr2ogr
ogr2ogr `
  -f "PostgreSQL" `
  -nln "census.blockgroups_2020" `
  -nlt MULTIPOLYGON `
  -t_srs EPSG:4326 `
  -lco "GEOM_TYPE=geography" `
  -lco "GEOMETRY_NAME=geog" `
  -overwrite `
  PG:"host=localhost port=5432 dbname=musa_509 user=postgres password=000929" `
  "data\censusBG\tl_2020_42_bg.shp"

  # Load bus stop
  csvsql `
  --db "postgresql://postgres:000929@localhost:5432/musa_509" `
  --insert `
  --overwrite `
  --create-if-not-exists `
  --db-schema "septa" `
  --tables "bus_stops" `
  "data\station\bus\stops.txt"