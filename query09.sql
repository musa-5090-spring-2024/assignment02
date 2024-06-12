/*
With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall.
`ST_MakePoint()` and functions like that are not allowed.

    **Structure (should be a single value):**
    ```sql
    (
        geo_id text
    )
    ```
*/

with meyerson as (
    select geog
    from phl.pwd_parcels
    where ogc_fid = 533551
)

select blocks.geoid::text as geo_id
from meyerson
inner join census.blockgroups_2020 as blocks
    on st_covers(blocks.geog, meyerson.geog)
