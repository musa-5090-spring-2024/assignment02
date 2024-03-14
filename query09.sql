-- Active: 1709164238938@@127.0.0.1@5432@musa509a2
/*
With a query involving PWD parcels and census block groups, find the geo_id of the
 block group that contains Meyerson Hall. ST_MakePoint() and functions like that are
  not allowed.
*/

WITH meyersonhall AS (
    SELECT *
    FROM phl.pwd_parcels
    WHERE address ILIKE '220-30 S 34TH ST'
)

SELECT bg.geoid
FROM census.blockgroups_2020 AS bg
INNER JOIN meyersonhall ON ST_INTERSECTS(bg.geog, meyersonhall.geog)






