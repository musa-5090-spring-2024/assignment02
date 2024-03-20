WITH shape_geoms AS (
    SELECT
        shape_id,
        ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326) ORDER BY shape_pt_sequence)) AS geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),

trip_lengths AS (
    SELECT
        shape_id,
        geog,
        CAST(ROUND(ST_LENGTH(geog::geography)) AS INTEGER) AS length
    FROM shape_geoms
),

trip_info AS (
    SELECT
        route_id,
        trip_headsign,
        shape_id
    FROM septa.bus_trips
    GROUP BY route_id, trip_headsign, shape_id
)

SELECT
    trip_info.route_id AS route_short_name,
    trip_info.trip_headsign AS trip_headsign,
    trip_lengths.geog AS shape_geog,
    trip_lengths.length AS shape_length
FROM trip_lengths
JOIN trip_info ON trip_info.shape_id = trip_lengths.shape_id
ORDER BY shape_length DESC
LIMIT 2
