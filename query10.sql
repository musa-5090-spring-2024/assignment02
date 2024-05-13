WITH stop_bus_distance AS (
    SELECT
        rs.stop_id AS rail_stop_id,
        rs.stop_name AS rail_stop_name,
        rs.stop_lon AS rail_stop_lon,
        rs.stop_lat AS rail_stop_lat,
        bs.stop_id AS bus_stop_id,
        bs.stop_name AS bus_stop_name,
        bs.stop_lon AS bus_stop_lon,
        bs.stop_lat AS bus_stop_lat,
        ST_Distance(
            ST_SetSRID(ST_MakePoint(rs.stop_lon, rs.stop_lat), 4326),
            ST_SetSRID(ST_MakePoint(bs.stop_lon, bs.stop_lat), 4326)
        ) AS distance_meters
    FROM
        septa.rail_stops rs
    CROSS JOIN LATERAL (
        SELECT
            stop_id,
            stop_name,
            stop_lon,
            stop_lat
        FROM
            septa.bus_stops
        ORDER BY
            ST_Distance(
                ST_SetSRID(ST_MakePoint(rs.stop_lon, rs.stop_lat), 4326),
                ST_SetSRID(ST_MakePoint(bus_stops.stop_lon, bus_stops.stop_lat), 4326)
            ) ASC
        LIMIT 1
    ) bs
)
SELECT
    rail_stop_id AS stop_id,
    rail_stop_name AS stop_name,
    CASE
        WHEN distance_meters <= 50 THEN 'Closest Bus Stop: ' || bus_stop_name || ', just '||round((distance_meters * 3.28084)::numeric, 4)||' feet away!'	
    END AS stop_desc,
    rail_stop_lon AS stop_lon,
    rail_stop_lat AS stop_lat
FROM
    stop_bus_distance;