/*
With a query, find out how many census block groups Penn's main campus fully contains.
Discuss which dataset you chose for defining Penn's campus.

    **Structure (should be a single value):**
    ```sql
    (
        count_block_groups integer
    )
    ```

    **Discussion:**
    I chose the water department parcels dataset to define Penn's campus. To isolate Penn
    properties, I used a where statement in my query. Since the ownership records are inconsistent,
    I use several combinations of names to catch all of the Penn-owned parcels. I then buffered these
    parcels by 50 meters to account for small gaps, especially streets, unioned them together, and selected
    the block groups that fall entirely inside the buffered polygon.
*/

with penn as (
    select st_union(st_buffer(geog, 50)::geometry) as buff
    from phl.pwd_parcels
    where (
        (owner1 like 'TRS%' or owner1 like '%TRUSTEE%')
        and (owner1 like '%UNIV%' or owner1 like 'PENN')
    )
    or (
        (owner1 like 'TRS%' or owner1 like '%TRUSTEE%')
        and (owner2 like '%UNIV%' or owner2 like 'PENN')
    )
    or (
        (owner2 like 'TRS%' or owner2 like '%TRUSTEE%')
        and (owner2 like '%UNIV%' or owner2 like 'PENN')
    )
    or owner1 like 'WISTAR INSTITUTE OF ANATO'
    or owner1 like 'TRUSTEES FOR MOORE'
    or (owner1 like 'UNIVERSITY%' or owner2 like 'PENNSYLVANIA')

)

select count(*)::integer as count_block_groups
from penn
inner join census.blockgroups_2020 as blocks
    on st_covers(penn.buff::geography, blocks.geog)
