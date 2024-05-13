SELECT
    COUNT(bg.geog) AS count_block_groups
FROM
    census.blockgroups_2020 bg
JOIN
    azavea.neighborhoods n
ON
    n.name = 'UNIVERSITY_CITY'
    AND ST_Intersects(n.geog, bg.geog);