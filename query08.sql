WITH parcels_of_penn AS (
  SELECT * 
  FROM phl_pwd_parcels AS parcels
  WHERE
        owner1 ILIKE 'TRUSTEES OF THE U%'
		OR (owner1 ILIKE 'THE TRUSTEES%' AND owner2 ILIKE 'UNIVERSITY OF PA')
        OR (owner1 ILIKE 'UNIVERSITY OF%' AND owner2 ILIKE 'PENN')
        OR owner1 ILIKE 'TR UNIV OF PENNA'
        OR owner1 ILIKE 'TRS UNIV OF PENN'
        OR owner1 ILIKE 'TRS UNIV PENN'
        OR owner1 ILIKE 'TR UNIVERSITY OF PENN'
        OR owner1 ILIKE 'TR THE UNIVERSITY OF'
        OR owner1 ILIKE 'THE UNIVERSITY OF PENN'
),
campus_bg AS (
  SELECT COUNT(*) AS count_bg
  FROM census_blockgroups_2020 bg
  JOIN parcels_of_penn ON ST_Contains(parcels_of_penn.geom::geometry, bg.geom::geometry)
)
SELECT count_bg
FROM campus_bg;
--For defining Penn's campus, I chose the Philadelphia Water Department Stormwater Billing Parcels dataset (phl.pwd_parcels). This dataset contains information about ownerships of land parcels in Philadelphia. I used a combination of ownership patterns to identify the potential parcels associated with the University of Pennsylvania.