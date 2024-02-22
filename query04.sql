/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
find the two routes with the longest trips.
*/


WITH trip_summary AS (
    SELECT
        trips.shape_id,
        MIN(trips.route_id) AS route_id,
        MIN(trips.trip_headsign) AS trip_headsign
    FROM
        septa.bus_trips AS trips
    GROUP BY
        trips.shape_id
),

shape_summary AS (
    SELECT
        shape.shape_id,
        ST_MAKELINE(
            ARRAY_AGG(
                ST_SETSRID(ST_MAKEPOINT(shape.shape_pt_lon, shape.shape_pt_lat), 4326)
                ORDER BY shape.shape_pt_sequence
            )
        )::geography AS shape_geog,
        ST_LENGTH(
            ST_MAKELINE(
                ARRAY_AGG(
                    ST_SETSRID(ST_MAKEPOINT(shape.shape_pt_lon, shape.shape_pt_lat), 4326)
                    ORDER BY shape.shape_pt_sequence
                )
            )::geography
        ) AS shape_length
    FROM
        septa.bus_shapes AS shape
    GROUP BY
        shape.shape_id
)

SELECT
    t.route_id AS route_short_name,
    t.trip_headsign,
    s.shape_geog,
    ROUND(s.shape_length) AS shape_length
FROM
    trip_summary AS t
INNER JOIN
    shape_summary AS s
    ON
        t.shape_id = s.shape_id
ORDER BY
    s.shape_length DESC
LIMIT 2;
