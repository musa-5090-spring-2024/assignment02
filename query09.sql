/* With a query involving PWD parcels and census block groups, find the geo_id of the block group 
that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

Structure (should be a single value):
(
    geo_id text
)
*/

SET search_path='public';  
SELECT cbg.geoid
FROM census.blockgroups_2020 AS cbg
JOIN phl.pwd_parcels AS parcel
ON ST_Intersects(cbg.geog::geometry, ST_SetSRID(ST_GeomFromText('POINT(-75.192584 39.952415)'), 4269)::geography);