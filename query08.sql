/*With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.*/

with
penn_buildings as (
    select * from phl.pwd_parcels
    where owner1 in ('THE CHILDRENS HOSPITAL', 'UNIVERSITY OF', 'TRUSTEES OF THE', 'TRUSTEES OF', 'CHILDRENS'' HOSPITAL OF PH', 'CHILDRENS HOSPITAL OF PHI', 'CHILDRENS HOSPITAL', 'PENNA DEPT OF', 'THE UNIVERSITY OF PENNA', 'TR UNIV OF PENNA', 'TR UNIVERSITY OF PENNA', 'TRS OF THE UNIV OF PENNA', 'TRS UNIV OF PENN', 'TRUSTEES OF THE UNIVERSITY OF PENNSYLVAN', 'TRUSTEES OF UNIV OF PENN', 'TRUSTEES UNIV OF PENNA', 'UNIVERSITY OF PENNSYLVANI', 'UPENN 2 HOLDINGS LLC', 'UNIVERSITY OF PENN TRS', 'THE TRUSTEES OF', 'TRUSTEES OF THE UNIVERSIT')
),

university_city as (
    select * from azavea.neighborhoods
    where listname = 'University City'
),

penn_campus as (
    select st_convexhull(st_collect(penn_buildings.geog::geometry)) as geom
    from penn_buildings
    inner join university_city
        on st_intersects(university_city.geog, penn_buildings.geog)
)

select count(*) as count_block_groups
from penn_campus, census.blockgroups_2020
where st_contains(penn_campus.geom, blockgroups_2020.geog::geometry)
