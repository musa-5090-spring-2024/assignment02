SELECT COUNT(*) AS block_groups_fully_contained
FROM
    census.blockgroups_2020 AS bg
INNER JOIN
    azavea.neighborhoods AS n ON ST_CONTAINS(n.geog::GEOMETRY, bg.geog::GEOMETRY)
WHERE
    n.name = 'UNIVERSITY_CITY';
