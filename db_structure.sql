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

-- Create schema to store all the datasets
create schema if not exists census;
create schema if not exists septa;
create schema if not exists phl;
create schema if not exists azavea;

-- Preprocess census.population_2020
-- select only the columns we need, delete unnecessary rows, and change the data types of the columns
create table census.temp_census as
select
    "GEO_ID" as geoid,
    "NAME" as geoname,
    "P1_001N" as total
from census.population_2020;

drop table census.population_2020;

alter table census.temp_census rename to population_2020;

delete from census.population_2020
where geoid = 'Geography';

alter table census.population_2020
alter column geoid type text;

alter table census.population_2020
alter column geoname type text;

alter table census.population_2020
alter column total type integer
using total::integer;

-- Preprocess septa.bus_stops
-- Change data types
-- Add a column to the septa.bus_stops table to store the geometry of each stop.
-- Create an index on the geog column.
alter table septa.bus_stops
add column if not exists geog geography;

update septa.bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

create index if not exists septa_bus_stops__geog__idx
on septa.bus_stops using gist
(geog);

alter table septa.bus_stops
alter column stop_id type text,
alter column stop_name type text,
alter column stop_lat type double precision,
alter column stop_lon type double precision,
alter column location_type type text,
alter column parent_station type text,
alter column zone_id type text,
alter column wheelchair_boarding type integer;

--- Preprocess census.blockgroups_2020
-- Change data types
-- Create an index on the geog column.
alter table census.blockgroups_2020
alter column geoid type text;

create index if not exists census_blockgroups_2020__geog__idx
on census.blockgroups_2020 using gist
(geog);

--- Prepocess phl.pwd_parcels
-- Change data types
alter table phl.pwd_parcels
alter column address type text;


--- Preprocess septa.rail_stops
-- Add a column to the septa.rail_stops table to store the geometry of each stop.
-- Create an index on the geog column.
alter table septa.rail_stops
add column if not exists geog geography;

update septa.rail_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

create index if not exists septa_rail_stops__geog__idx
on septa.rail_stops using gist
(geog);
