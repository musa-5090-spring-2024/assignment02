/* You're tasked with giving more contextual information to rail stops to fill 
the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS 
functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, 
build a description (alias as stop_desc) for each stop. Feel free to supplement 
with other datasets (must provide link to data used so it's reproducible), and
other methods of describing the relationships. SQL's CASE statements may be 
helpful for some operations.

Structure:

(
    stop_id integer,
    stop_name text,
    stop_desc text,
    stop_lon double precision,
    stop_lat double precision
)
As an example, your stop_desc for a station stop may be something like 
"37 meters NE of 1234 Market St" (that's only an example, feel free to be 
creative, silly, descriptive, etc.)

Tip when experimenting: Use subqueries to limit your query to just a few 
rows to keep query times faster. Once your query is giving you answers you
 want, scale it up. E.g., instead of FROM tablename, use FROM (SELECT * FROM 
 tablename limit 10) as t. */

select * from septa.rail_stops limit 10;
select * from azavea.neighborhoods limit 10;
select * from phl.pwd_parcels limit 10;


distance 
direction 
which neighborhood 


WITH stops AS (
    SELECT 
        stop_id, 
        stop_name, 
        stop_lon,
        stop_lat,
        ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography AS geog,
        ST_Centroid(ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography) as stop_ct
    FROM septa.rail_stops
)

SELECT 
    stops.stop_id,
    stops.stop_name,
    CONCAT(
        ROUND(ST_Distance(stops.geog, pwd.geog)::numeric), 
        ' meters ', 
        CASE 
            WHEN degrees(ST_Azimuth(stop_ct, ST_Centroid(pwd.geog))) < 22.5 THEN 'N'
            WHEN degrees(ST_Azimuth(stop_ct, ST_Centroid(pwd.geog))) < 67.5 THEN 'NE'
            WHEN degrees(ST_Azimuth(stop_ct, ST_Centroid(pwd.geog))) < 112.5 THEN 'E'
            WHEN degrees(ST_Azimuth(stop_ct, ST_Centroid(pwd.geog))) < 157.5 THEN 'SE'
            WHEN degrees(ST_Azimuth(stop_ct, ST_Centroid(pwd.geog))) < 202.5 THEN 'S'
            WHEN degrees(ST_Azimuth(stop_ct, ST_Centroid(pwd.geog))) < 247.5 THEN 'SW'
            WHEN degrees(ST_Azimuth(stop_ct, ST_Centroid(pwd.geog))) < 292.5 THEN 'W'
            WHEN degrees(ST_Azimuth(stop_ct, ST_Centroid(pwd.geog))) < 337.5 THEN 'NW'
            ELSE 'N'
        END,
        ' of ',
        pwd.address
    ) AS stop_desc,
    stops.stop_lon,
    stops.stop_lat
FROM stops
CROSS JOIN phl.pwd_parcels AS pwd;

npm run test  MUSA-cloud-assignment2/__tests__/test_query01.js