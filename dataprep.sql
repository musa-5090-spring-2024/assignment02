User
CREATE TABLE septa_bus_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    location_type TEXT,
    parent_station TEXT,
    zone_id TEXT,
    wheelchair_boarding INTEGER
);
CREATE TABLE septa_bus_routes (
    route_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_url TEXT
);
CREATE TABLE septa_bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    block_id TEXT,
    direction_id TEXT,
    shape_id TEXT
);
CREATE TABLE septa_bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);
CREATE TABLE septa_rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);
CREATE TABLE census_population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

COPY septa_bus_stops (stop_id, stop_name, stop_lat, stop_lon, location_type, parent_station, zone_id, wheelchair_boarding)
FROM 'C:\Program Files\PostgreSQL\Assignment2\gtfs_public\google_bus\stops.csv' 
DELIMITER ',' 
CSV HEADER;
ALTER TABLE septa_bus_stops
ADD COLUMN geom geometry(Point, 4326); 
UPDATE septa_bus_stops
SET geom = ST_SetSRID(ST_MakePoint(stop_lon::float, stop_lat::float), 4326);
SELECT * FROM septa_bus_stops;

COPY septa_bus_routes (route_id, route_short_name, route_long_name, route_type, route_color, route_text_color, route_url)
FROM 'C:\Program Files\PostgreSQL\Assignment2\gtfs_public\google_bus\routes.csv' 
DELIMITER ',' 
CSV HEADER;
SELECT * FROM septa_bus_routes;

COPY septa_bus_trips (route_id, service_id, trip_id, trip_headsign, block_id, direction_id, shape_id)
FROM 'C:\Program Files\PostgreSQL\Assignment2\gtfs_public\google_bus\trips.csv' 
DELIMITER ',' 
CSV HEADER;
SELECT* FROM septa_bus_trips;

COPY septa_bus_shapes (shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence)
FROM 'C:\Program Files\PostgreSQL\Assignment2\gtfs_public\google_bus\shapes.csv' 
DELIMITER ',' 
CSV HEADER;
SELECT * FROM septa_bus_shapes;

COPY septa_rail_stops (stop_id, stop_name, stop_desc, stop_lat, stop_lon, zone_id, stop_url)
FROM 'C:\Program Files\PostgreSQL\Assignment2\gtfs_public\google_rail\stops.csv' 
DELIMITER ',' 
CSV HEADER;
ALTER TABLE septa_rail_stops
ADD COLUMN geom geometry(Point, 4326); 
UPDATE septa_rail_stops
SET geom = ST_SetSRID(ST_MakePoint(stop_lon::float, stop_lat::float), 4326);
SELECT * FROM septa_rail_stops;

COPY census_population_2020 (geoid, geoname, total)
FROM 'C:\Program Files\PostgreSQL\Assignment2\DECENNIALPL2020.P1_2024-05-04T203312\DECENNIALPL2020.P1-Data.csv' 
DELIMITER ',' 
CSV HEADER;
SELECT * FROM census_population_2020;

SELECT * FROM phl_pwd_parcels;
SELECT * FROM azavea_neighborhoods;
SELECT * FROM census_blockgroups_2020;

ALTER TABLE phl_pwd_parcels ADD COLUMN geom geometry(Geometry, 4326);
UPDATE phl_pwd_parcels 
SET geom = ST_GeomFromWKB(wkb_geometry);
CREATE INDEX phl_pwd_parcels_geom_idx ON phl_pwd_parcels USING GIST (geom);
SELECT * FROM phl_pwd_parcels;

ALTER TABLE azavea_neighborhoods ADD COLUMN geom geometry(Geometry, 4326);
UPDATE azavea_neighborhoods 
SET geom = ST_GeomFromWKB(wkb_geometry);
CREATE INDEX azavea_neighborhoods_geom_idx ON phl_pwd_parcels USING GIST (geom);
SELECT * FROM azavea_neighborhoods;

ALTER TABLE census_blockgroups_2020
ADD COLUMN geom geometry(Point, 4326); 
UPDATE census_blockgroups_2020
SET geom = ST_SetSRID(ST_MakePoint(intptlon::float, intptlat::float), 4326);
SELECT * FROM census_blockgroups_2020;


SELECT * FROM pg_extension WHERE extname LIKE 'postgis%';
CREATE EXTENSION postgis;
