/*
  With a query, find out how many census block groups Penn's main campus fully contains. 
  Discuss which dataset you chose for defining Penn's campus.
*/

WITH UniversityCity AS (
    SELECT geog
    FROM azavea.neighborhoods
    WHERE name = 'UNIVERSITY_CITY'
),
ContainedBlockGroups AS (
    SELECT bg.geoid, bg.geog
    FROM census.blockgroups_2020 AS bg
    JOIN UniversityCity AS uc
    ON ST_Contains(uc.geog, bg.geog)
)
SELECT COUNT(*) AS count_block_groups
FROM ContainedBlockGroups;






