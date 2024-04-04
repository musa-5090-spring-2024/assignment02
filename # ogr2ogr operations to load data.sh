# ogr2ogr operations to load data
# to use the .env file with all the credentials, in terminal, type source.env

ogr2ogr \
  -f "PostgreSQL" \
  PG:"host=localhost port=5432 dbname=Assignment2 user=oliveratwood password=anthropocene" \
  -nln phl.pwd_parcels \
  -nlt MULTIPOLYGON \
  -t_srs EPSG:4326 \
  -lco GEOMETRY_NAME=geog \
  -lco GEOM_TYPE=GEOGRAPHY \
  -overwrite \
  "/Users/oliveratwood/Downloads/PWD_PARCELS/PWD_PARCELS.shp"


ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=5432 dbname=Assignment2 user=oliveratwood password=anthropocene" \
    -nln azavea.neighborhoods \
    -nlt MULTIPOLYGON \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "/Users/oliveratwood/Downloads/Neighborhoods_Philadelphia.geojson"


ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=5432 dbname=Assignment2 user=oliveratwood password=anthropocene" \
    -nln census.blockgroups_2020 \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "/Users/oliveratwood/Downloads/tl_2020_42_bg/tl_2020_42_bg.shp"