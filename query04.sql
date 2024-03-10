-- Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.

-- Your query should run in under two minutes.

WITH
shape_trip AS (
    SELECT
        trips.trip_headsign,
        shape_id,
        trips.route_id,
        ST_MAKELINE(
            ARRAY_AGG(
                ST_SETSRID(ST_MAKEPOINT(shape.shape_pt_lon, shape.shape_pt_lat), 4326)
                ORDER BY shape.shape_pt_sequence
            )
        )::GEOGRAPHY AS shape_geog,
        ROUND(ST_LENGTH(ST_MAKELINE(
            ARRAY_AGG(
                ST_SETSRID(ST_MAKEPOINT(shape.shape_pt_lon, shape.shape_pt_lat), 4326)
                ORDER BY shape.shape_pt_sequence
            )
        )::GEOGRAPHY, TRUE)::NUMERIC) AS shape_length
    FROM septa.bus_shapes AS shape
    LEFT JOIN septa.bus_trips AS trips USING (shape_id)
    GROUP BY shape_id, trips.trip_headsign, trips.route_id
)

SELECT
    final_frame.route_short_name AS route_short_name,
    previous.trip_headsign AS trip_headsign,
    previous.shape_geog AS shape_geog,
    previous.shape_length AS shape_length
FROM shape_trip AS previous
LEFT JOIN septa.bus_routes AS final_frame USING (route_id)
GROUP BY route_short_name, trip_headsign, shape_geog, shape_length
ORDER BY shape_length DESC
LIMIT 2
