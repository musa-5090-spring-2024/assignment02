/* With a query, find out how many census block groups Penn's main campus fully contains. 
Discuss which dataset you chose for defining Penn's campus.

Structure (should be a single value):

(
    count_block_groups integer
)
Discussion:

*/

WITH penn_campus AS (
   SELECT ST_GeomFromText(
        'POLYGON((-75.18360159853358 39.95474892173111, -75.20136622025659 39.95706679621946, 
   		-75.20559981165864 39.952117311720166, -75.19308422678641 39.94303890445427,
   		-75.18360159853358 39.95474892173111))', 
        4326)::geography AS geog
)

SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 AS bg
inner join penn_campus
on ST_Covers(penn_campus.geog, bg.geog);