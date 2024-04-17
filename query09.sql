/*
With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall.
ST_MakePoint() and functions like that are not allowed.
*/


-- Get the geography of the Meyerson Hall parcel
WITH meyerson AS (
    SELECT geog AS mys_geog
    FROM phl.pwd_parcels
    WHERE address = '220-30 S 34TH ST'
)
-- Find the geo_id of the block group that contains Meyerson Hall
SELECT geoid::text AS geo_id
FROM census.blockgroups_2020 bg
JOIN meyerson m ON ST_Covers(bg.geog, m.mys_geog);
