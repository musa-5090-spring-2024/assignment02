#Steps for Assignment 2:

#1) Create a new database for the assignment by pasting the chunk in terminal

createdb --port 5432 musa509assign_2

#2) Set up the .env file with the required details

#3) Download the data

# First downloading the bus stops data
curl -L https://github.com/septadev/GTFS/releases/download/v202402070/gtfs_public.zip > gtfs_public.zip
unzip -o gtfs_public.zip -d gtfs_public
unzip -o gtfs_public/google_bus.zip -d google_bus
unzip -o gtfs_public/google_rail.zip -d google_rail

#modifies the content of the google stop data to remove all carriage stop characters like s/ \r//g that are in the windows environment
#which does work in macos
sed -i 's/\r//g' google_bus/stops.txt
psql \
  -h localhost \
  -p 5432 \
  -U avani \
  -d musa509assign_2 \
  -c "\copy septa.bus_stops FROM 'google_bus/stops.txt' DELIMITER ',' CSV HEADER;"

#doing the same thing for route data
# Use sed to replace \r\n with \n in the google_bus/routes.txt file
sed -i 's/\r//g' google_bus/routes.txt
psql \
  -h localhost \
  -p 5432 \
  -U avani \
  -d musa509assign_2 \
  -c "\copy septa.bus_routes FROM 'google_bus/routes.txt' DELIMITER ',' CSV HEADER;"

sed -i 's/\r//g' google_bus/trips.txt
psql \
  -h localhost \
  -p 5432 \
  -U avani \
  -d musa509assign_2 \
  -c "\copy septa.bus_trips FROM 'google_bus/trips.txt' DELIMITER ',' CSV HEADER;"

sed -i 's/\r//g' google_bus/shapes.txt
psql \
  -h localhost \
  -p 5432 \
  -U avani \
  -d musa509assign_2 \
  -c "\copy septa.bus_shapes FROM 'google_bus/shapes.txt' DELIMITER ',' CSV HEADER;"

sed -i 's/\r//g' google_rail/stops.txt
psql \
  -h localhost \
  -p 5432 \
  -U avani \
  -d musa509assign_2 \
-c "\copy septa.rail_stops FROM 'google_rail/stops.txt' DELIMITER ',' CSV HEADER;"

#Now downloading the census data
curl -L 'https://api.census.gov/data/2020/dec/pl?get=NAME,GEO_ID,P1_001N&for=block%20group:*&in=state:42%20county:*' > census_population_2020.json
unzip -o census_population.zip -d census_population

#then using python I converted json into csv, see censuswork.py file for steps

#now adding this to postgres
psql \
  -h localhost \
  -p 5432 \
  -U avani \
  -d musa509assign_2 \
  -c "\copy census.population_2020 FROM 'census_population_2020.csv' DELIMITER ',' CSV HEADER;"

  # Download and unzip PWD Stormwater Billing parcel data
curl -L https://opendata.arcgis.com/datasets/84baed491de44f539889f2af178ad85c_0.zip > phl_pwd_parcels.zip
unzip -o phl_pwd_parcels.zip -d phl_pwd_parcels

# load parcel data into database
ogr2ogr \
    -f "PostgreSQL" \
    -nln phl.pwd_parcels \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    PG:"host=localhost port=5432 dbname=musa509assign_2 user=avani password=sqlpassword" \
    phl_pwd_parcels/PWD_PARCELS.shp

    # Download philly neighborhood data
curl -L https://github.com/azavea/geo-data/raw/9e0ac39840803d6218f4503e8a16c7aad0807de4/Neighborhoods_Philadelphia/Neighborhoods_Philadelphia.geojson > Neighborhoods_Philadelphia.geojson
# load neighbourhoods data into database
ogr2ogr \
    -f "PostgreSQL" \
    -nln azavea.neighborhoods \
    -nlt MULTIPOLYGON \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    PG:"host=localhost port=5432 dbname=musa509assign_2 user=avani password=sqlpassword" \
    Neighborhoods_Philadelphia.geojson

# Download and unzip census data
curl -L https://www2.census.gov/geo/tiger/TIGER2020/BG/tl_2020_42_bg.zip > census_blockgroups_2020.zip
unzip -o census_blockgroups_2020.zip -d census_blockgroups_2020
# Load census data into database
ogr2ogr \
    -f "PostgreSQL" \
    -nln census.blockgroups_2020 \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    PG:"host=localhost port=5432 dbname=musa509assign_2 user=avani password=sqlpassword" \
    census_blockgroups_2020/tl_2020_42_bg.shp

#and that adds all of our data!