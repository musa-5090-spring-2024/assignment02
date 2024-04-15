-- With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

SELECT blockgroup.geoid AS geo_id
FROM phl.pwd_parcels AS pwd
LEFT JOIN census.blockgroups_2020 AS blockgroup
    ON ST_COVERS(blockgroup.geog, pwd.geog)
WHERE pwd.address = '220-30 S 34TH ST'