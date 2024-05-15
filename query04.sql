
' Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips'


WITH trip_shapes AS (
    SELECT
        trips.route_short_name,
        trips.trip_headsign,
        ST_MakeLine(shapes.shape_pt::geometry ORDER BY shapes.shape_pt_sequence) AS shape_geom
    FROM
        bus_trips AS trips
    JOIN
        bus_shapes AS shapes ON trips.shape_id = shapes.shape_id
    GROUP BY
        trips.route_short_name, trips.trip_headsign
),
trip_lengths AS (
    SELECT
        route_short_name,
        trip_headsign,
        ST_Length(shape_geom::geography) AS shape_length
    FROM
        trip_shapes
)
SELECT
    route_short_name,
    trip_headsign,
    shape_geom::geography AS shape_geog,
    ROUND(shape_length::numeric) AS shape_length
FROM
    trip_lengths
ORDER BY
    shape_length DESC
LIMIT 2;
