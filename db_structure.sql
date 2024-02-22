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

    psql -U postgres -d musa-5090 -f db_structure.sql

*/


-- Preprocess census.population_2020
-- select only the columns we need, delete unnecessary rows, and change the data types of the columns

ALTER TABLE census.population_2020
DROP COLUMN "P1_002N",
DROP COLUMN "P1_003N",
DROP COLUMN "P1_004N",
DROP COLUMN "P1_005N",
DROP COLUMN "P1_006N",
DROP COLUMN "P1_007N",
DROP COLUMN "P1_008N",
DROP COLUMN "P1_009N",
DROP COLUMN "P1_010N",
DROP COLUMN "P1_011N",
DROP COLUMN "P1_012N",
DROP COLUMN "P1_013N",
DROP COLUMN "P1_014N",
DROP COLUMN "P1_015N",
DROP COLUMN "P1_016N",
DROP COLUMN "P1_017N",
DROP COLUMN "P1_018N",
DROP COLUMN "P1_019N",
DROP COLUMN "P1_020N",
DROP COLUMN "P1_021N",
DROP COLUMN "P1_022N",
DROP COLUMN "P1_023N",
DROP COLUMN "P1_024N",
DROP COLUMN "P1_025N",
DROP COLUMN "P1_026N",
DROP COLUMN "P1_027N",
DROP COLUMN "P1_028N",
DROP COLUMN "P1_029N",
DROP COLUMN "P1_030N",
DROP COLUMN "P1_031N",
DROP COLUMN "P1_032N",
DROP COLUMN "P1_033N",
DROP COLUMN "P1_034N",
DROP COLUMN "P1_035N",
DROP COLUMN "P1_036N",
DROP COLUMN "P1_037N",
DROP COLUMN "P1_038N",
DROP COLUMN "P1_039N",
DROP COLUMN "P1_040N",
DROP COLUMN "P1_041N",
DROP COLUMN "P1_042N",
DROP COLUMN "P1_043N",
DROP COLUMN "P1_044N",
DROP COLUMN "P1_045N",
DROP COLUMN "P1_046N",
DROP COLUMN "P1_047N",
DROP COLUMN "P1_048N",
DROP COLUMN "P1_049N",
DROP COLUMN "P1_050N",
DROP COLUMN "P1_051N",
DROP COLUMN "P1_052N",
DROP COLUMN "P1_053N",
DROP COLUMN "P1_054N",
DROP COLUMN "P1_055N",
DROP COLUMN "P1_056N",
DROP COLUMN "P1_057N",
DROP COLUMN "P1_058N",
DROP COLUMN "P1_059N",
DROP COLUMN "P1_060N",
DROP COLUMN "P1_061N",
DROP COLUMN "P1_062N",
DROP COLUMN "P1_063N",
DROP COLUMN "P1_064N",
DROP COLUMN "P1_065N",
DROP COLUMN "P1_066N",
DROP COLUMN "P1_067N",
DROP COLUMN "P1_068N",
DROP COLUMN "P1_069N",
DROP COLUMN "P1_070N",
DROP COLUMN "P1_071N",

ALTER TABLE census.population_2020
RENAME COLUMN "GEO_ID" TO geoid,
RENAME COLUMN "NAME" TO geoname,
RENAME COLUMN "P1_001N" TO total;

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
