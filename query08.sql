/*
With a query, find out how many census block groups Penn's main campus fully contains. 
Discuss which dataset you chose for defining Penn's campus.

Discussion:
I choose the neighborhood dataset under 'azavea' schema where 'name'='UNIVERSITY_CITY' to represent UPenn's campus.
*/

-- Get the geography representing Penn's main campus
WITH campus AS (
    SELECT geog AS campus_geog
    FROM azavea.neighborhoods
    WHERE name = 'UNIVERSITY_CITY'
)
-- Count the number of census block groups fully contained within Penn's main campus
SELECT COUNT(*)::integer AS count_block_groups
FROM census.blockgroups_2020 bg
JOIN campus c ON ST_Covers(c.campus_geog, bg.geog);
