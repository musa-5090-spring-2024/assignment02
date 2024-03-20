-- Q9:
SELECT
    bg.geoid
FROM
    census.blockgroups_2020 AS bg
JOIN
    phl.pwd_parcels parcels ON ST_Intersects(bg.geog::geometry, parcels.geog::geometry)
WHERE
    parcels.address = '220-30 S 34TH ST'
