create schema if not exists septa;
create schema if not exists phl;
create schema if not exists azavea;
create schema if not exists census;

-- Create tables for bus stops
drop table if exists septa.bus_stops;
create table septa.bus_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    location_type TEXT,
    parent_station TEXT,
    zone_id TEXT,
    wheelchair_boarding INTEGER
);

copy septa.bus_stops
from 'D:/Spring_2024/Cloud/assignment02/data/gtfs_public/google_bus/stops.txt'
WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- Create tables for bus routes
drop table if exists septa.bus_routes;
create table septa.bus_routes (
    route_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_url TEXT
);

copy septa.bus_routes
from 'D:/Spring_2024/Cloud/assignment02/data/gtfs_public/google_bus/routes.txt'
WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- Create tables for bus trips
drop table if exists septa.bus_trips;
create table septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    block_id TEXT,
    direction_id TEXT,
    shape_id TEXT
);

copy septa.bus_trips
from 'D:/Spring_2024/Cloud/assignment02/data/gtfs_public/google_bus/trips.txt'
WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- Create tables for bus shapes
drop table if exists septa.bus_shapes;
create table septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);

copy septa.bus_shapes
from 'D:/Spring_2024/Cloud/assignment02/data/gtfs_public/google_bus/shapes.txt'
WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- Create tables for rail stops
drop table if exists septa.rail_stops;
create table septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);

copy septa.rail_stops
from 'D:/Spring_2024/Cloud/assignment02/data/gtfs_public/google_rail/stops.txt'
WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- Create tables for census population 2020
drop table if exists census.population_2020;
create table census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

copy census.population_2020
from 'D:/Spring_2024/Cloud/assignment02/data/population_2020.csv'
WITH (FORMAT csv, HEADER true);

create extension if not exists postgis;
