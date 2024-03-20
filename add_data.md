# Load bus stop
  csvsql `
  --db "postgresql://postgres:000929@localhost:5432/musa_509" `
  --insert `
  --overwrite `
  --create-if-not-exists `
  --db-schema "septa" `
  --tables "bus_stops" `
  "data\station\bus\stops.txt"

ALTER TABLE septa.bus_stops
ALTER COLUMN stop_name TYPE TEXT

# Load bus routes
  csvsql `
  --db "postgresql://postgres:000929@localhost:5432/musa_509" `
  --insert `
  --overwrite `
  --create-if-not-exists `
  --db-schema "septa" `
  --tables "bus_routes" `
  "data\station\bus\routes.txt"

# Load bus trips
  csvsql `
  --db "postgresql://postgres:000929@localhost:5432/musa_509" `
  --insert `
  --overwrite `
  --create-if-not-exists `
  --db-schema "septa" `
  --tables "bus_trips" `
  "data\station\bus\trips.txt"

# Load bus shapes
  csvsql `
  --db "postgresql://postgres:000929@localhost:5432/musa_509" `
  --insert `
  --overwrite `
  --create-if-not-exists `
  --db-schema "septa" `
  --tables "bus_shapes" `
  "data\station\bus\shapes.txt"

# Load rail stops
  csvsql `
  --db "postgresql://postgres:000929@localhost:5432/musa_509" `
  --insert `
  --overwrite `
  --create-if-not-exists `
  --db-schema "septa" `
  --tables "rail_stops" `
  "data\station\rail\stops.txt"

# Load pwd parcels
  ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=musa_509 user=postgres password=000929" `
    -nln phl.pwd_parcels `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "D:\UPenn\Class\Spring 2024\Cloud\musa-cloud-assignment02\data\pwd\PWD_PARCELS.shp"

# Load neighborhood
  ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=musa_509 user=postgres password=000929" `
    -nln azavea.neighborhoods `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "D:\UPenn\Class\Spring 2024\Cloud\open-geo-data\Neighborhoods_Philadelphia\Neighborhoods_Philadelphia.geojson"

# Load Pennsylvania census blockgroup 2020
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

ALTER TABLE census.blockgroups_2020
ALTER COLUMN geoid TYPE TEXT

# Load population data
  DROP TABLE IF EXISTS census.population_2020;
  CREATE TABLE census.population_2020 (
      geoid TEXT,
      geoname TEXT,
      total INTEGER
  );

  COPY census.population_2020
  FROM 'D:\UPenn\Class\Spring 2024\Cloud\musa-cloud-assignment02\data\population\PL2020.csv'
  WITH (FORMAT csv, HEADER true, ENCODING 'utf-8');














# Density
with

-- Create a CTE for the bus stops that includes a geography column
septa_bus_stops as (
    select
        *,
        st_makepoint(stop_lon, stop_lat)::geography as geog
    from septa.bus_stops
)

-- Select the geoid, geography, and the number of bus stops per sq km.
select
    blockgroups.geoid,
    blockgroups.geog,
    count(bus_stops.*) / st_area(blockgroups.geog) * 1000000 as bus_stops_per_sqkm
from census.blockgroups_2020 as blockgroups
left join septa_bus_stops as bus_stops
    on st_covers(blockgroups.geog, bus_stops.geog)
group by
    blockgroups.geoid, blockgroups.geog
order by
    bus_stops_per_sqkm desc

# Nearest bus stop for each property parcel
with

-- Create a CTE for the bus stops that includes a geography column
septa_bus_stops as (
    select
        *,
        st_makepoint(stop_lon, stop_lat)::geography as geog
    from septa.bus_stops
)

-- Find the bus stop nearest to each property parcel. This is a K-Nearest
-- Neighbors (KNN) calculation with K=1.
select
    pwd_parcels.address,
    pwd_parcels.geog,
    nearest_bus_stop.*
from phl.pwd_parcels
cross join lateral (
    select *
    from septa_bus_stops as bus_stops
    order by pwd_parcels.geog <-> bus_stops.geog
    limit 1
) as nearest_bus_stop