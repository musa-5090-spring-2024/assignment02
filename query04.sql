/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.
*/

WITH
shape_line AS (
    SELECT
        shape_id,
        ST_MAKELINE(
            ARRAY_AGG(
                ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326)
                ORDER BY shape_pt_sequence
            )
        )::GEOGRAPHY AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),

shape_trip AS (
    SELECT
        trips.trip_headsign,
        shape.shape_id,
        trips.route_id,
        shape.shape_geog
    FROM shape_line AS shape
    LEFT JOIN septa.bus_trips AS trips USING (shape_id)
    GROUP BY shape.shape_id, trips.trip_headsign, trips.route_id, shape.shape_geog
)

SELECT
    routes.route_short_name AS route_short_name,
    shape_trip.trip_headsign AS trip_headsign,
    ROUND(ST_LENGTH(shape_trip.shape_geog, TRUE)::NUMERIC) AS shape_length,
    shape_trip.shape_geog AS shape_geog    
FROM shape_trip
LEFT JOIN septa.bus_routes AS routes USING (route_id)
GROUP BY route_short_name, trip_headsign, shape_geog, shape_length
ORDER BY shape_length DESC
LIMIT 2

