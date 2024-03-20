-- With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

-- use university city neighborhood as Penn's main campus

SELECT *
FROM (
    SELECT CASE WHEN neighborhoods.name = 'UNIVERSITY_CITY' THEN COUNT(blockgroup.*) END::INTEGER AS count_block_groups
    FROM azavea.neighborhoods AS neighborhoods
    LEFT JOIN census.blockgroups_2020 AS blockgroup
        ON ST_COVERS(neighborhoods.geog, blockgroup.geog)
    GROUP BY neighborhoods.name
) AS subquery
WHERE count_block_groups IS NOT NULL;
