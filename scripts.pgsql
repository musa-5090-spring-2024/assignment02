CREATE SCHEMA septa;
CREATE SCHEMA phl;
CREATE SCHEMA azavea;
CREATE SCHEMA census;

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE septa.bus_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    location_type TEXT,
    parent_station TEXT,
    zone_id TEXT,
    wheelchair_boarding INTEGER
);

COPY septa.bus_stops
FROM '/Users/shuaiwang/Documents/MUSA-Cloud/MUSA-cloud-assignment2/data/google_bus/stops.txt'
WITH (FORMAT csv, HEADER true);

select * from septa.bus_stops

CREATE TABLE septa.bus_routes (
    route_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_url TEXT
);

COPY septa.bus_routes
FROM '/Users/shuaiwang/Documents/MUSA-Cloud/MUSA-cloud-assignment2/data/google_bus/routes.txt'
WITH (FORMAT csv, HEADER true);

select * from septa.bus_routes


CREATE TABLE septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    block_id TEXT,
    direction_id TEXT,
    shape_id TEXT
);

COPY septa.bus_trips
FROM '/Users/shuaiwang/Documents/MUSA-Cloud/MUSA-cloud-assignment2/data/google_bus/trips.txt'
WITH (FORMAT csv, HEADER true);

select * from septa.bus_trips


CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);

COPY septa.bus_shapes
FROM '/Users/shuaiwang/Documents/MUSA-Cloud/MUSA-cloud-assignment2/data/google_bus/shapes.txt'
WITH (FORMAT csv, HEADER true);

select * from septa.bus_shapes


CREATE TABLE septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);

COPY septa.rail_stops
FROM '/Users/shuaiwang/Documents/MUSA-Cloud/MUSA-cloud-assignment2/data/google_rail/stops.txt'
WITH (FORMAT csv, HEADER true);

select * from septa.bus_shapes limit 100


CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);


COPY census.population_2020 (geoid, geoname, total)
FROM '/Users/shuaiwang/Documents/MUSA-Cloud/MUSA-cloud-assignment2/data/DECENNIALPL2020.P1_2024-03-08T113934/census.csv'
WITH (FORMAT csv, HEADER true);

select * from census.population_2020 limit 100



ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=5432 dbname=musa_as2 user=postgres password=postgres" \
    -nln phl.pwd_parcels \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "MUSA-cloud-assignment2/data/PWD_PARCELS/PWD_PARCELS.shp"

ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=5432 dbname=musa_as2 user=postgres password=postgres" \
    -nln azavea.neighborhoods \
    -nlt MULTIPOLYGON \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "MUSA-cloud-assignment2/data/Neighborhoods_Philadelphia.geojson"

ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=5432 dbname=musa_as2 user=postgres password=postgres" \
    -nln census.blockgroups_2020 \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "MUSA-cloud-assignment2/data/tl_2020_42_bg/tl_2020_42_bg.shp"