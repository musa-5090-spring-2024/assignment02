-- Q10:
SELECT
    rs.stop_id,
    rs.stop_name,
    LTRIM(CONCAT(
        ROUND(ST_Distance(rs.geog, bs.geog)::numeric, 2), ' feet ',
        CASE
            WHEN degrees(ST_Azimuth(rs.geog, bs.geog)) BETWEEN 0 AND 22.5 THEN 'N'
            WHEN degrees(ST_Azimuth(rs.geog, bs.geog)) BETWEEN 22.5 AND 67.5 THEN 'NE'
            WHEN degrees(ST_Azimuth(rs.geog, bs.geog)) BETWEEN 67.5 AND 112.5 THEN 'E'
            WHEN degrees(ST_Azimuth(rs.geog, bs.geog)) BETWEEN 112.5 AND 157.5 THEN 'SE'
            WHEN degrees(ST_Azimuth(rs.geog, bs.geog)) BETWEEN 157.5 AND 202.5 THEN 'S'
            WHEN degrees(ST_Azimuth(rs.geog, bs.geog)) BETWEEN 202.5 AND 247.5 THEN 'SW'
            WHEN degrees(ST_Azimuth(rs.geog, bs.geog)) BETWEEN 247.5 AND 292.5 THEN 'W'
            WHEN degrees(ST_Azimuth(rs.geog, bs.geog)) BETWEEN 292.5 AND 337.5 THEN 'NW'
            ELSE 'N'
        END, ' of ', bs.stop_name
    )) AS stop_desc,
    rs.stop_lon,
    rs.stop_lat
FROM
    (SELECT * FROM septa.rail_stops) rs
CROSS JOIN LATERAL
    (SELECT
        bs.stop_name,
        bs.geog,
        ST_Distance(rs.geog::geometry, bs.geog::geometry) AS distance
     FROM
        septa.bus_stops bs
     ORDER BY
        rs.geog::geometry <-> bs.geog::geometry
     LIMIT 1) bs


