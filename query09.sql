with meyerson as (
    select * from phl.pwd_parcels
    where address = '220-30 S 34TH ST'
)

select blockgroups_2020.geoid
from meyerson, census.blockgroups_2020
where st_covers(blockgroups_2020.geog, meyerson.geog)
