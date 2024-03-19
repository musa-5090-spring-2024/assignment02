/*

This file contains the SQL commands to prepare the database for your queries.
Before running this file, you should have created your database, created the
schemas (see below), and loaded your data into the database.

Creating your schemas
---------------------

You can create your schemas by running the following statements in PG Admin:

    create schema if not exists septa;
    create schema if not exists phl;
    create schema if not exists census;

Also, don't forget to enable PostGIS on your database:

    create extension if not exists postgis;

Loading your data
-----------------

After you've created the schemas, load your data into the database specified in
the assignment README.

Finally, you can run this file either by copying it all into PG Admin, or by
running the following command from the command line:

    psql -U postgres -d <YOUR_DATABASE_NAME> -f db_structure.sql

*/

-- Add a column to the septa.bus_stops table to store the geometry of each stop.
alter table septa.bus_stops
add column if not exists geog geography;

update septa.bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_bus_stops__geog__idx
on septa.bus_stops using gist
(geog);

CREATE TABLE septa.bus_routes (
    route_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_url TEXT
);
CREATE TABLE septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    block_id TEXT,
    direction_id TEXT,
    shape_id TEXT
);

CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);
CREATE TABLE septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);

CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);




ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=week03 user=postgres password=123456"`
    -nln phl.pwd_parcels `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "C:\Users\Lenovo\Desktop\MUSA 509\PWD_PARCELS\PWD_PARCELS.shp"

    ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=week03 user=postgres password=123456"`
    -nln azavea.neighborhoods `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "C:\Users\Lenovo\Desktop\MUSA 509\Neighborhoods_Philadelphia.geojson"

     ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=week03 user=postgres password=123456"`
    -nln census.population_2020 `
    -overwrite `
    "C:\Users\Lenovo\Desktop\MUSA 509\DECENNIALPL2020.P1_2024-02-24T212040\DECENNIALPL2020.P1-Data.xlsx"

    ALTER TABLE census.population_2020
ALTER COLUMN geoid TYPE VARCHAR(20),
ALTER COLUMN geoname TYPE VARCHAR(20),
ALTER COLUMN total TYPE INTEGER;
