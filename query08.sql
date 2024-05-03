-- Active: 1708112526321@@127.0.0.1@5432@assignment02
/*With a query, find out how many census block groups Penn's main campus fully contains. 
Discuss which dataset you chose for defining Penn's campus.

Structure (should be a single value):

(
    count_block_groups integer
)

Discussion: I found a "Philadelphia Universities and Colleges" dataset from Open Data Philly. This
dataset separates all parts of Penn's campus into individual parcels so it is difficult to qualify 
which exactly belong to main campus without additional analysis, but this is fairly close. 

I am also receiving an error about mixed SRID geometries that I cannot seem to fix...

*/
SHOW search_path;
SET search_path='public';  

-- Update the SRID of the universities table
ALTER TABLE phl.universities
ALTER COLUMN geog TYPE geography(MultiPolygon, 4269)
USING ST_SetSRID(geog::geometry, 4269)::geography;

-- Query to find the count of block groups
SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 AS cbg
JOIN phl.universities AS uni
ON ST_Intersects(cbg.geog, uni.geog)
WHERE uni.name = 'University of Pennsylvania';