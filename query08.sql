/*

With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

*/

WITH UPenn_buildings AS (
    SELECT * 
    FROM phl.pwd_parcels
    WHERE owner1 IN (
        'UNIVERSITY OF', 
        'THE TRUSTEES OF'
        'TRUSTEES OF THE', 
        'THE UNIVERSITY OF PENN'
        'PENNA DEPT OF', 
        'THE UNIVERSITY OF PENNA', 
        'TR UNIV OF PENNA', 
        'TRS OF THE UNIV OF PENNA', 
        'TRUSTEES OF U OF P'
        'TRS UNIV OF PENN', 
        'TRUSTEES OF THE UNIVERSITY OF PENNSYLVAN', 
        'TRUSTEES U OF P'
        'TRUSTEES UNIV OF PENNA', 
        'UNIVERSITY OF PENNSYLVANI', 
    )
),

UPenn_campus AS (
    SELECT st_convexhull(st_collect(Upenn_buildings.geog::geometry)) AS geom
    FROM Upenn_buildings
    JOIN azavea.neighborhoods ON st_intersects(azavea.neighborhoods.geog, Upenn_buildings.geog)
    WHERE azavea.neighborhoods.listname = 'University City'
)

SELECT COUNT(*) AS count_block_groups
FROM Upenn_campus
JOIN census.blockgroups_2020 ON st_contains(Upenn_campus.geom, blockgroups_2020.geog::geometry);
