SELECT
    rs.stop_id,
    rs.stop_name,
    LTRIM(CONCAT(
        ROUND(ST_Distance(rs.geom, bs.geom)::numeric, 2), ' meters ',
        CASE
            WHEN degrees(ST_Azimuth(rs.geom, bs.geom)) BETWEEN 0 AND 22.5 THEN 'N'
            WHEN degrees(ST_Azimuth(rs.geom, bs.geom)) BETWEEN 22.5 AND 67.5 THEN 'NE'
            WHEN degrees(ST_Azimuth(rs.geom, bs.geom)) BETWEEN 67.5 AND 112.5 THEN 'E'
            WHEN degrees(ST_Azimuth(rs.geom, bs.geom)) BETWEEN 112.5 AND 157.5 THEN 'SE'
            WHEN degrees(ST_Azimuth(rs.geom, bs.geom)) BETWEEN 157.5 AND 202.5 THEN 'S'
            WHEN degrees(ST_Azimuth(rs.geom, bs.geom)) BETWEEN 202.5 AND 247.5 THEN 'SW'
            WHEN degrees(ST_Azimuth(rs.geom, bs.geom)) BETWEEN 247.5 AND 292.5 THEN 'W'
            WHEN degrees(ST_Azimuth(rs.geom, bs.geom)) BETWEEN 292.5 AND 337.5 THEN 'NW'
            ELSE 'N'
        END, ' of ', bs.stop_name
    )) AS stop_desc,
    rs.stop_lon,
    rs.stop_lat
FROM
    (SELECT * FROM septa_rail_stops) rs
CROSS JOIN LATERAL
    (SELECT
        bs.stop_name,
        bs.geom,
        ST_Distance(rs.geom::geometry, bs.geom::geometry) AS distance
     FROM
        septa_bus_stops bs
     ORDER BY
        rs.geom::geometry <-> bs.geom::geometry
     LIMIT 1) bs;


