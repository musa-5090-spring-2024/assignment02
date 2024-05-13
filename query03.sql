SELECT
    pwd_parcels.address AS parcel_address,
    closest_bus_stop.stop_name,
    closest_bus_stop.distance
FROM phl.pwd_parcels
CROSS JOIN LATERAL (
    SELECT
        *,
        ROUND(cast(ST_DISTANCE(pwd_parcels.geog, stops.geog) AS NUMERIC), 2) AS distance
    FROM septa.bus_stops AS stops
    ORDER BY pwd_parcels.geog <-> stops.geog
    LIMIT 1
) AS closest_bus_stop
ORDER BY closest_bus_stop.distance DESC



CREATE TABLE septa.shapes (
  shape_id text NOT NULL,
  shape_pt_lat double precision NOT NULL,
  shape_pt_lon double precision NOT NULL,
  shape_pt_sequence int NOT NULL
);
CREATE INDEX shapes_shape_key ON shapes (shape_id);

-- Create a table to store the shape geometries
CREATE TABLE shape_geoms (
  shape_id text NOT NULL,
  shape_geom geometry('LINESTRING', 4326),
  CONSTRAINT shape_geom_pkey PRIMARY KEY (shape_id)
);
CREATE INDEX shape_geoms_key ON shapes (shape_id);

CREATE TABLE location_types (
  location_type int PRIMARY KEY,
  description text
);

CREATE TABLE stops (
  stop_id text,
  stop_name text DEFAULT NULL,
  stop_lat double precision,
  stop_lon double precision,
	location_type integer  REFERENCES location_types(location_type),
  parent_station integer,
  zone_id text,
	wheelchair_boarding integer,
  stop_geom geometry('POINT', 4326),
  CONSTRAINT stops_pkey PRIMARY KEY (stop_id)
);

INSERT INTO location_types(location_type, description) VALUES
(0,'stop'),
(1,'station'),
(2,'station entrance');


CREATE TABLE trips (
  route_id text NOT NULL,
  service_id text NOT NULL,
  trip_id text NOT NULL,
  trip_headsign text,
  direction_id int,
  block_id text,
  shape_id text,
  CONSTRAINT trips_pkey PRIMARY KEY (trip_id)
);
CREATE INDEX trips_trip_id ON trips (trip_id);

COPY calendar(service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,
start_date,end_date) FROM 'C:/Users/jonat/Documents/musa-5090/week04/gtfs_public/google_bus/calendar.txt' DELIMITER ',' CSV HEADER;
COPY trips(route_id,service_id,trip_id,trip_headsign,direction_id,block_id,shape_id)
FROM 'C:/Users/Public/google_bus/trips.txt' DELIMITER ',' CSV HEADER;
COPY shapes(shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence)
FROM 'C:/Users/Public/google_bus/shapes.txt' DELIMITER ',' CSV HEADER;
COPY stops(stop_id,stop_name,stop_lat,stop_lon,location_type, parent_station, zone_id, wheelchair_boarding) 
FROM 'C:/Users/Public/google_bus/stops.csv' DELIMITER ','
CSV HEADER;



INSERT INTO shape_geoms
SELECT shape_id, ST_MakeLine(array_agg(
  ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))
FROM shapes
GROUP BY shape_id;

UPDATE stops
SET stop_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat),4326);