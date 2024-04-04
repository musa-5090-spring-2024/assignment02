WITH meyerson_parcels AS (
    SELECT parcels.geog
    FROM phl.pwd_parcels AS parcels
    WHERE parcels.address = '220-30 S 34TH ST'
)

SELECT bg.geoid AS geo_id
FROM census.blockgroups_2020 AS bg
INNER JOIN meyerson_parcels
    ON ST_INTERSECTS(bg.geog, meyerson_parcels.geog)
