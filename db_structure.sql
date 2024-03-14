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


create schema if not exists indego;

drop table if exists septa.bus_stops;

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
create extension if not exists postgis;


COPY septa.bus_stops
FROM 'C:\Users\Public\MUSA509\A2\stops.txt'
WITH (FORMAT csv,HEADER true);

alter table septa.bus_stops
add column if not exists geog geography;

update septa.bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_bus_stops__geog__idx
on septa.bus_stops using gist
(geog);






drop table if exists septa.bus_routes;

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
FROM 'C:\Users\Public\MUSA509\busnew\routes.txt'
WITH (FORMAT csv,HEADER true);


drop table if exists septa.bus_trips;

CREATE TABLE septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    direction_id TEXT,
    block_id TEXT,   
    shape_id TEXT
);

COPY septa.bus_trips
FROM 'C:\Users\Public\MUSA509\busnew\trips.txt'
WITH (FORMAT csv,HEADER true);


drop table if exists septa.bus_shapes;

CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);

COPY septa.bus_shapes
FROM 'C:\Users\Public\MUSA509\busnew\shapes.txt'
WITH (FORMAT csv,HEADER true);


drop table if exists septa.bus_shapes;

CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);

COPY septa.bus_shapes
FROM 'C:\Users\Public\MUSA509\bus\shapesclean.txt'
WITH (FORMAT csv,HEADER true);


drop table if exists septa.rail_stops;

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
FROM 'C:\Users\Public\MUSA509\rail\stops.txt'
WITH (FORMAT csv,HEADER true);


drop table if exists census.population_2020;

CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

COPY census.population_2020
FROM 'C:/Users/Public/MUSA509/DECENNIALPL2020.P1-Data.csv'
WITH (FORMAT csv,HEADER true);



drop table if exists phl.landmark;

CREATE TABLE phl.landmark (
    landmarkname TEXT,
    landmarkaddress TEXT,
    geog geography
);

COPY septa.bus_shapes
FROM 'C:\Users\Public\MUSA509\A2\landmark.geojson'
WITH (FORMAT csv,HEADER true);