/*
With a query, find out how many census block groups Penn's main campus fully contains.
*/

WITH penn_parcels AS (
    SELECT
        owner1,
        address,
        geog
    FROM phl.pwd_parcels
    WHERE
        owner1 ILIKE 'THE TRUSTEES OF'
        OR owner1 ILIKE 'THE TRUSTEES OF THE'
        OR owner1 ILIKE 'THE UNIVERSITY OF PENNA'
        OR owner1 ILIKE 'TR UNIV OF PENNA'
        OR owner1 ILIKE 'TRS UNIV OF PENN'
        OR owner1 ILIKE 'TRS UNIV PENN'
        OR owner1 ILIKE 'TRUSTEES FOR MOORE'
        OR owner1 ILIKE 'TRUSTEES OF'
        OR owner1 ILIKE 'TRUSTEES OF THE'
        OR owner1 ILIKE 'TRUSTEES OF THE U OF PENN'
        OR owner1 ILIKE 'TRUSTEES OF THE UNIV OF'
        OR owner1 ILIKE 'TRUSTEES OF THE UNIVERSIT'
        OR owner1 ILIKE 'TRUSTEES OF THE UNIVERSITY OF PENNSYLVAN'
        OR owner1 ILIKE 'TRUSTEES OF U OF P'
        OR owner1 ILIKE 'TRUSTEES OF UNIV OF PENN'
        OR owner1 ILIKE 'TRUSTEES U OF P'
        OR owner1 ILIKE 'TRUSTEES UNIV OF PENNA'
        OR owner1 ILIKE 'TRUSTEES UNIVERSITY'
        OR owner1 ILIKE 'UNIVERSITY OF'
        OR owner1 ILIKE 'UNIVERSITY OF PENN TRS'
        OR owner1 ILIKE 'UNIVERSITY OF PENNA TR'
        OR owner1 ILIKE 'UNIVERSITY OF PENNSYLVANI'
        OR owner1 ILIKE 'UPENN 2 HOLDINGS LLC'
        OR owner1 ILIKE 'TR UNIVERSITY OF PENNA'
        OR owner1 ILIKE 'TR THE UNIVERSITY OF'
        OR owner1 ILIKE 'TRS OF THE UNIV OF PENNA'
        OR owner1 ILIKE 'TRUSTEES OF UNIVERSITY'
        OR owner1 ILIKE 'TRUSTEEES OF THE UNIVERSI'
        OR owner1 ILIKE 'TRST''S OF THE UNIVERSITY'
),

selected_bg AS (
    SELECT bg.geoid
    FROM census.blockgroups_2020 AS bg
    INNER JOIN penn_parcels AS pp
        ON ST_INTERSECTS(bg.geog, pp.geog)
    GROUP BY bg.geoid, bg.geog
    HAVING SUM(ST_AREA(pp.geog)) >= ST_AREA(bg.geog)
)

SELECT COUNT(*) AS count_block_groups
FROM selected_bg
