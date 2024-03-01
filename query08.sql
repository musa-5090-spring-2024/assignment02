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
    buffer
    envelope
    convex hull
    union
*/

with penn as (
    select
        st_union(st_buffer(geog, 50)::geometry) as buff
    from phl.pwd_parcels
    where ((owner1 like 'TRS%' OR owner1 like '%TRUSTEE%')
        and (owner1 like '%UNIV%' or owner1 like 'PENN')) or
        ((owner1 like 'TRS%' OR owner1 like '%TRUSTEE%')
        and (owner2 like '%UNIV%' or owner2 like 'PENN')) or
        ((owner2 like 'TRS%' OR owner2 like '%TRUSTEE%')
        and (owner2 like '%UNIV%' or owner2 like 'PENN')) or
		owner1 like 'WISTAR INSTITUTE OF ANATO' or
		owner1 like 'TRUSTEES FOR MOORE'  or
        (owner1 like 'UNIVERSITY%' OR owner2 like 'PENNSYLVANIA')
        
)

select
	count(*)::integer as count_block_groups
from penn
inner join census.blockgroups_2020 as blocks
	on st_covers(penn.buff::geography, blocks.geog)