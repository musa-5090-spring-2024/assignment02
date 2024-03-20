WITH penn_parcels AS (
  SELECT * 
  FROM phl.pwd_parcels AS parcels
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
  FROM census.blockgroups_2020 bg, penn_parcels
  WHERE ST_Contains(penn_parcels.geog::geometry, bg.geog::geometry)
)
SELECT count_bg
FROM campus_bg;
