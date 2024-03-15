WITH meyerson_hall_location AS (
    SELECT
        ST_Centroid(geog::geometry) AS geom
    FROM
        phl.pwd_parcels
    WHERE
        objectid = 950
)

SELECT
    bg.geoid AS geo_id
FROM
    census.blockgroups_2020 bg,
    meyerson_hall_location mh
WHERE
    ST_Within(mh.geom, bg.geog::geometry);
