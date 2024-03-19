/*
You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed.

Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), 
and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. 

Feel free to supplement with other datasets (must provide link to data used so it's reproducible), 
and other methods of describing the relationships. SQL's `CASE` statements may be helpful for some operations.
*/

ALTER TABLE IF EXISTS septa.rail_stops DROP COLUMN IF EXISTS geog;
ALTER TABLE septa.rail_stops ADD COLUMN geog geography(Point, 4326);

UPDATE septa.rail_stops AS rs
SET geog = ST_SetSRID(ST_MakePoint(rs.stop_lon, rs.stop_lat), 4326);

UPDATE septa.rail_stops AS rs
SET    
    stop_desc = 
    CASE 
        WHEN n.name IS NOT NULL THEN 
            'Rail stop located in ' || n.name || ' neighborhood.'
        ELSE 
            'Rail stop location context not available.'
    END
FROM azavea.neighborhoods AS n
WHERE ST_Covers(n.geog, rs.geog) -- The neighborhood that contains the rail stop
AND rs.stop_desc IS NULL; -- Update only if the description is not already set

SELECT
    rs.stop_id AS stop_id,
    rs.stop_name AS stop_name,
    rs.stop_desc AS stop_desc,
    rs.stop_lon AS stop_lon,
    rs.stop_lat AS stop_lat
FROM
    septa.rail_stops AS rs;
