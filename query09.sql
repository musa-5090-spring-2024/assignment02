WITH meyerson AS (
    SELECT pwd.geog
    FROM phl.pwd_parcels AS pwd
    WHERE pwd.address = '220-30 S 34TH ST'
)

SELECT bg.geoid AS geo_id
FROM census.blockgroups_2020 AS bg
INNER JOIN meyerson ON ST_INTERSECTS(bg.geog, meyerson.geog)
