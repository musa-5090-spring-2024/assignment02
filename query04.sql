/* Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, 
find the two routes with the longest trips. */

WITH trip_table AS (
    SELECT
        trips.shape_id,
        trips.route_id,
        trips.trip_headsign
    FROM
        septa.bus_trips AS trips
    GROUP BY
        trips.shape_id, trips.route_id, trips.trip_headsign
),

shape_table AS (
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
                ))::geography
        ) AS shape_length
    FROM
        septa.bus_shapes AS shape
    GROUP BY
        shape.shape_id
)

SELECT
    trip_table.route_id AS route_short_name,
    trip_table.trip_headsign,
    shape_table.shape_geog,
    ROUND(shape_table.shape_length) AS shape_length
FROM
    trip_table
INNER JOIN
    shape_table
    ON
    trip_table.shape_id = shape_table.shape_id
ORDER BY
    shape_table.shape_length DESC
LIMIT 2;