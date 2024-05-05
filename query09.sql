SELECT
    bg.geoid
FROM
    census_blockgroups_2020 AS bg
JOIN
    phl_pwd_parcels AS parcels ON ST_Intersects(bg.geom::geometry, parcels.geom::geometry)
WHERE
    address = '220-30 S 34TH ST';
