SELECT COUNT(DISTINCT bg.geoid) AS count_block_groups
FROM phl.pwd_parcels AS pwd
FULL JOIN phl.neighborhoods AS nhoods
    ON ST_INTERSECTS(nhoods.geog, pwd.geog)
FULL JOIN census.blockgroups_2020 AS bg
    ON ST_COVERS(bg.geog, pwd.geog)
WHERE
    pwd.name = 'UNIVERSITY_CITY'
    AND pwd.owner1 = 'TRUSTEES OF THE UNIVERSIT'
