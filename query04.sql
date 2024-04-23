/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, 
  find the two routes with the longest trips.
*/


WITH shape_lines AS (
    SELECT
        shape_id,
        ST_MakeLine(ARRAY_AGG(ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326) ORDER BY shape_pt_sequence)) AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),
trip_shapes AS (
    SELECT
        bt.route_id,
        bt.trip_headsign,
        sl.shape_geog,
        ST_Length(sl.shape_geog::geography, true) AS shape_length -- Using true for spheroid calculation
    FROM septa.bus_trips AS bt
    JOIN shape_lines AS sl ON bt.shape_id = sl.shape_id
),
ranked_trips AS (
    SELECT
        br.route_short_name,
        ts.trip_headsign,
        ts.shape_geog,
        ROUND(ts.shape_length) AS shape_length,
        ROW_NUMBER() OVER (PARTITION BY br.route_id ORDER BY ts.shape_length DESC) AS rn
    FROM trip_shapes AS ts
    JOIN septa.bus_routes AS br ON ts.route_id = br.route_id
)
SELECT
    route_short_name,
    trip_headsign,
    shape_geog,
    shape_length
FROM ranked_trips
WHERE rn = 1
ORDER BY shape_length DESC
LIMIT 2;




