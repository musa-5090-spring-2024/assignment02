WITH shape_lines AS (
    SELECT
        bs.shape_id,
        ST_MAKELINE(ST_SETSRID(ST_MAKEPOINT(bs.shape_pt_lon, bs.shape_pt_lat), 4326)) AS shape_geog
    FROM
        septa.bus_shapes AS bs
    GROUP BY
        bs.shape_id
),

trip_shapes AS (
    SELECT
        bt.trip_id,
        bt.route_id,
        bt.trip_headsign,
        sl.shape_geog,
        ST_LENGTH(sl.shape_geog::geography) AS shape_length
    FROM
        septa.bus_trips AS bt
    INNER JOIN shape_lines AS sl ON bt.shape_id = sl.shape_id
),

ranked_trips AS (
    SELECT
        br.route_short_name,
        ts.trip_headsign,
        ts.shape_geog,
        ROUND(ts.shape_length) AS shape_length,
        ROW_NUMBER() OVER (PARTITION BY br.route_id ORDER BY ts.shape_length DESC) AS rn
    FROM
        trip_shapes AS ts
    INNER JOIN septa.bus_routes AS br ON ts.route_id = br.route_id
)

SELECT
    route_short_name,
    trip_headsign,
    shape_geog,
    shape_length
FROM
    ranked_trips
WHERE
    rn = 1
ORDER BY
    shape_length DESC
LIMIT 2;
