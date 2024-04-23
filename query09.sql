/*
  With a query involving PWD parcels and census block groups, 
  find the geo_id of the block group that contains Meyerson Hall. 
  ST_MakePoint() and functions like that are not allowed.
*/


WITH meyerson_parcels AS (
    SELECT geog
    FROM phl.pwd_parcels
    WHERE address = '220-30 S 34TH ST'
)
SELECT DISTINCT bg.geoid AS geo_id
FROM census.blockgroups_2020 AS bg
JOIN meyerson_parcels
ON ST_COVERS(bg.geog, meyerson_parcels.geog) OR ST_INTERSECTS(bg.geog, meyerson_parcels.geog);








