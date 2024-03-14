-- Active: 1709164238938@@127.0.0.1@5432@musa509a2
/*
With a query, find out how many census block groups Penn's main campus fully contains.
 Discuss which dataset you chose for defining Penn's campus.
*/

WITH penn_parcels AS (
    SELECT
        owner1,
        address,
        geog
    FROM phl.pwd_parcels
    where owner1 in ('THE CHILDRENS HOSPITAL', 'UNIVERSITY OF', 'TRUSTEES OF THE', 'TRUSTEES OF', 'CHILDRENS'' HOSPITAL OF PH', 'CHILDRENS HOSPITAL OF PHI', 'CHILDRENS HOSPITAL', 'PENNA DEPT OF', 'THE UNIVERSITY OF PENNA', 'TR UNIV OF PENNA', 'TR UNIVERSITY OF PENNA', 'TRS OF THE UNIV OF PENNA', 'TRS UNIV OF PENN', 'TRUSTEES OF THE UNIVERSITY OF PENNSYLVAN', 'TRUSTEES OF UNIV OF PENN', 'TRUSTEES UNIV OF PENNA', 'UNIVERSITY OF PENNSYLVANI', 'UPENN 2 HOLDINGS LLC', 'UNIVERSITY OF PENN TRS', 'THE TRUSTEES OF', 'TRUSTEES OF THE UNIVERSIT')
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







