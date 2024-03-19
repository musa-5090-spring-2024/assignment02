select 
    blocks.geoid as geo_id
from 
(
    select 
        ogc_fid,
        address,
        owner1,
        geog
    from phl.pwd_parcels
    where address like '%220-30 S 34TH ST%' and owner1 like '%PENN%'
) as meyerson_parcel

join

(
    select
        geoid,
        geog
    from census.blockgroups_2020
) as blocks

on st_intersects (
	meyerson_parcel.geog::geography,
    blocks.geog::geography
);