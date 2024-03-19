/* With a query involving PWD parcels and census block groups, find the geo_id of 
the block group that contains Meyerson Hall. ST_MakePoint() and functions like 
that are not allowed.

Structure (should be a single value):

(
    geo_id text
)
*/
With
    meyerson as(
        select * 
    from phl.pwd_parcels
    WHERE address ILIKE '220-30 S 34TH ST'
    )

select 
    bg.geoid as geo_id
    from census.blockgroups_2020 as bg
    join meyerson 
    on st_intersects(bg.geog, meyerson.geog)



