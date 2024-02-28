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
        *
    from phl.pwd_parcels
    where ((owner1 like 'TRS%' OR owner1 like 'TRUSTEE%')
        and (owner1 like '%UNIV%' or owner1 like 'PENN')) or
        ((owner1 like 'TRS%' OR owner1 like 'TRUSTEE%')
        and (owner2 like '%UNIV%' or owner2 like 'PENN')) or
        ((owner2 like 'TRS%' OR owner2 like 'TRUSTEE%')
        and (owner2 like '%UNIV%' or owner2 like 'PENN'))
)

