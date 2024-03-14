-- Active: 1709164238938@@127.0.0.1@5432@musa509a2
/*
You're tasked with giving more contextual information to rail stops to fill the 
stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions
 (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a 
 description (alias as stop_desc) for each stop. Feel free to supplement with 
 other datasets (must provide link to data used so it's reproducible), and other
  methods of describing the relationships. SQL's CASE statements may be helpful
   for some operations.
*/
SELECT 
    s.stop_id,
    s.stop_name,
    ('Approx. ' || ROUND(ST_Distance(s.geog, ST_ClosestPoint(p.geog::geometry, s.geog::geometry))::numeric, 2) || ' meters ' || 
    CASE 
        WHEN degrees(ST_Azimuth(s.geog, ST_Centroid(ST_ClosestPoint(p.geog::geometry, s.geog::geometry)))) BETWEEN 0 AND 22.5 OR degrees(ST_Azimuth(s.geog, ST_Centroid(ST_ClosestPoint(p.geog::geometry, s.geog::geometry)))) > 337.5 THEN 'N'
        WHEN degrees(ST_Azimuth(s.geog, ST_Centroid(ST_ClosestPoint(p.geog::geometry, s.geog::geometry)))) BETWEEN 22.5 AND 67.5 THEN 'NE'
        WHEN degrees(ST_Azimuth(s.geog, ST_Centroid(ST_ClosestPoint(p.geog::geometry, s.geog::geometry)))) BETWEEN 67.5 AND 112.5 THEN 'E'
        WHEN degrees(ST_Azimuth(s.geog, ST_Centroid(ST_ClosestPoint(p.geog::geometry, s.geog::geometry)))) BETWEEN 112.5 AND 157.5 THEN 'SE'
        WHEN degrees(ST_Azimuth(s.geog, ST_Centroid(ST_ClosestPoint(p.geog::geometry, s.geog::geometry)))) BETWEEN 157.5 AND 202.5 THEN 'S'
        WHEN degrees(ST_Azimuth(s.geog, ST_Centroid(ST_ClosestPoint(p.geog::geometry, s.geog::geometry)))) BETWEEN 202.5 AND 247.5 THEN 'SW'
        WHEN degrees(ST_Azimuth(s.geog, ST_Centroid(ST_ClosestPoint(p.geog::geometry, s.geog::geometry)))) BETWEEN 247.5 AND 292.5 THEN 'W'
        WHEN degrees(ST_Azimuth(s.geog, ST_Centroid(ST_ClosestPoint(p.geog::geometry, s.geog::geometry)))) BETWEEN 292.5 AND 337.5 THEN 'NW'
        ELSE 'Unknown'
    END || ' of ' || p.name) AS stop_desc,
    s.stop_lon,
    s.stop_lat
FROM 
    (SELECT * FROM septa.bus_stops LIMIT 10) AS s
CROSS JOIN LATERAL
    (SELECT name, geog
     FROM (SELECT name,  geog FROM phl.landmark) sub
     ORDER BY s.geog <-> geog
     LIMIT 1) AS p;









