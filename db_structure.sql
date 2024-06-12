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

-- Add a column to the septa.bus_shapes table to store the geometry of each shape point.
alter table septa.bus_shapes
add column if not exists geog geography;

update septa.bus_shapes
set geog = st_makepoint(shape_pt_lon, shape_pt_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_bus_shapes__geog__idx
on septa.bus_shapes using gist
(geog);

-- Create new table with shape lines.
CREATE TABLE septa.shape_geoms (
  shape_id text NOT NULL,
  shape_geom geography('LINESTRING', 4326),
  CONSTRAINT shape_geom_pkey PRIMARY KEY (shape_id)
);

INSERT INTO septa.shape_geoms
SELECT shape_id, ST_MakeLine(array_agg(
  ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence)) as shape_geom
FROM septa.bus_shapes
GROUP BY shape_id;

-- Create an index on shape_geoms.
create index if not exists septa_shape_geoms__geom__idx
on septa.shape_geoms using gist
(shape_geom);

--Create Wawa location table
create schema if not exists wawa;

CREATE TABLE wawa.locations (
  lon DOUBLE PRECISION,
  lat DOUBLE PRECISION,
  loc_name TEXT
);

COPY wawa.locations
FROM 'C:\Users\Public\Documents\musa\a2data\wawa.csv'
WITH (FORMAT csv, HEADER true);

select * from wawa.locations

--Ass geography to Wawa table
alter table wawa.locations
add column if not exists geog geography;

update wawa.locations
set geog = st_makepoint(lon, lat)::geography;

-- Create an the Wawa geog column
create index if not exists wawa_locations__geog__idx
on wawa.locations using gist
(geog);

-- Add a column to the septa.rail_stops table to store the geometry of each point.
alter table septa.rail_stops
add column if not exists geog geography;

update septa.rail_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_rail_stops__geog__idx
on septa.rail_stops using gist
(geog);