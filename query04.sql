 Active: 1709164238938@@127.0.0.1@5432@musa509a2
/*
Using the bus_shapes, bus_routes, and bus_trips tables from 
GTFS bus feed, find the two routes with the longest trips.
*/

WITH bus_shapes AS (
    SELECT
        shape_id,
        ST_MakeLine(ST_MakePoint(shape_pt_lon, shape_pt_lat) ORDER BY shape_pt_sequence)::geography AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),
trips_with_shapes AS (
    SELECT
        trips.route_id,
        trips.trip_id,
        trips.trip_headsign,
        shapes.shape_geog
    FROM septa.bus_trips AS trips
    INNER JOIN bus_shapes AS shapes USING (shape_id)
),
routes_with_trips AS (
    SELECT
        routes.route_id,
        routes.route_short_name,
        trips.trip_headsign,
        trips.shape_geog,
        ST_Length(trips.shape_geog) AS shape_length,
        ROW_NUMBER() OVER (
            PARTITION BY routes.route_id
            ORDER BY ST_Length(trips.shape_geog) DESC
        ) AS shape_length_rank
    FROM septa.bus_routes AS routes
    INNER JOIN trips_with_shapes AS trips USING (route_id)
)
SELECT
    routes.route_short_name,
    routes.trip_headsign,
    routes.shape_geog,
    ROUND(routes.shape_length) AS shape_length
FROM routes_with_trips AS routes
WHERE routes.shape_length_rank = 1
ORDER BY shape_length DESC
LIMIT 2;