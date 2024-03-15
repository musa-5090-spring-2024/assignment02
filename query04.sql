WITH route_lengths AS (
    SELECT
        br.route_short_name,
		bt.trip_headsign,
        ST_Length(ST_MakeLine(
            ST_SetSRID(ST_MakePoint(bs.shape_pt_lon, bs.shape_pt_lat), 4326)
            ORDER BY bs.shape_pt_sequence
        )) AS shape_length,
        ST_MakeLine(
            ST_SetSRID(ST_MakePoint(bs.shape_pt_lon, bs.shape_pt_lat), 4326)
            ORDER BY bs.shape_pt_sequence
        )::geography AS shape_geog
    FROM
        septa.bus_trips AS bt
        JOIN septa.bus_routes AS br ON bt.route_id = br.route_id
        JOIN septa.bus_shapes AS bs ON bt.shape_id = bs.shape_id
    GROUP BY
        br.route_short_name, bt.trip_headsign
)

SELECT
    route_short_name,
    trip_headsign,
    shape_length,
    shape_geog
FROM
    route_lengths
ORDER BY
    shape_length DESC
LIMIT
    2;
