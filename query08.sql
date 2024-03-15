SELECT
    COUNT(bg.*) AS count_block_groups
FROM
    census.blockgroups_2020 bg
JOIN
    azavea.neighborhoods n
ON
    ST_Within(ST_Centroid(bg.geog::geometry), n.geog::geometry)
WHERE
    n.name = 'UNIVERSITY_CITY';
-- I used univercity city row from the azavea neighborhoods table to define it as Penn's main campus.