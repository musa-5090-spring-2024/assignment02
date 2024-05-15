WITH upenn AS (
    SELECT geog AS upenn_geog
    FROM azavea.neighborhoods
    WHERE name = 'UNIVERSITY_CITY'
)
SELECT COUNT(*)::integer AS count_block_groups
FROM census.blockgroups_2020 bg
JOIN upenn c ON ST_Covers(c.upenn_geog, bg.geog);