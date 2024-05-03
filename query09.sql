--Question 9
--With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

--To do this, I will find the parcel ID of the parcel containing Meyerson Hall, and then find the census block that contains the parcel id.
--Open Data Philly has the PWD parcel visualized in ArcGIS online. From manually looking it up, we find that the parcel ID for meyerson hall is 263,026.
--the object ID is 	533508

WITH meyerson_parcel AS (
    SELECT b.geoid
    FROM
        census.blockgroups_2020 AS b
    INNER JOIN
        phl.pwd_parcels AS p ON ST_WITHIN(p.geog::geometry, b.geog::geometry)
    WHERE
        p.parcelid = '263026'
)

SELECT geoid FROM meyerson_parcel;
