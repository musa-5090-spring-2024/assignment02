 
 ' With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.'


WITH penn AS (
    SELECT geog AS penn_geog
    FROM neighborhoods
    WHERE neighborhood_name = 'UNIVERSITY_CITY'
)
SELECT COUNT(*)::integer AS count_block_groups
FROM censusblock2020 AS bg
JOIN penn ON ST_Contains(penn.penn_geog, bg.geog);

