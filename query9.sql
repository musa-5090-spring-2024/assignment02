' With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. `ST_MakePoint()` and functions like that are not allowed.
'
WITH meyerson_hall_parcel AS (
    SELECT geog
    FROM phl_water_dpt
    WHERE address ILIKE '%Meyerson Hall%'
),
meyerson_block_group AS (
    SELECT bg.geoid
    FROM censusblock2020 AS bg
    JOIN meyerson_hall_parcel AS mh ON ST_Contains(bg.geog, mh.geog)
)
SELECT geoid
FROM meyerson_block_group;
