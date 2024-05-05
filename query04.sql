WITH shape_geoms AS (
    SELECT
        shape_id,
        ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326) ORDER BY shape_pt_sequence)) AS geog
    FROM septa_bus_shapes
    GROUP BY shape_id
),

trips_lengths AS (
    SELECT
        shape_id,
        geog,
        CAST(ROUND(ST_LENGTH(geog::geography)) AS INTEGER) AS length
    FROM shape_geoms
),

trips_info AS (
    SELECT
        route_id,
        trip_headsign,
        shape_id
    FROM septa_bus_trips
    GROUP BY route_id, trip_headsign, shape_id
)

SELECT
    trips_info.route_id AS route_short_name,
    trips_info.trip_headsign AS trip_headsign,
    trips_lengths.geog AS shape_geog,
    trips_lengths.length AS shape_length
FROM trips_lengths
JOIN trips_info ON trips_info.shape_id = trips_lengths.shape_id
ORDER BY shape_length DESC
LIMIT 2
