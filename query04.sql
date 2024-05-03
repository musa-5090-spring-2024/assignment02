WITH bus_stop_shapes AS (
    SELECT
        shp.trip_id,
        shp.route_id,
        shp.trip_headsign,
        ST_MakeLine(ST_SetSRID(ST_MakePoint(bs.shape_pt_lon, bs.shape_pt_lat), 4326) ORDER BY bs.shape_pt_sequence) AS shape_geog
    FROM
        septa.bus_shapes AS bs
    JOIN
        septa.bus_trips AS shp ON bs.shape_id = shp.shape_id
    GROUP BY
        shp.trip_id, shp.route_id, shp.trip_headsign
),

bus_route_length AS (
    SELECT
        br.route_short_name,
        bss.trip_headsign,
        ROUND(ST_Length(bss.shape_geog::geography)) AS shape_length,
        bss.shape_geog
    FROM
        bus_stop_shapes AS bss
    JOIN
        septa.bus_routes AS br ON bss.route_id = br.route_id
)

SELECT
    route_short_name,
    trip_headsign,
    shape_length,
    shape_geog
FROM (
    SELECT DISTINCT ON (route_short_name)
        route_short_name,
        trip_headsign,
        shape_length::numeric,
        shape_geog
    FROM
        bus_route_length
    ORDER BY
        route_short_name, shape_length DESC
) as distinct_routes
ORDER BY
    shape_length DESC
LIMIT 2;
