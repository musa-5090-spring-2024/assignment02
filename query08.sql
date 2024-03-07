SELECT 
  COUNT(DISTINCT cbg.geoid) AS num_census_tracts
FROM 
  azavea.neighborhoods AS a
JOIN 
  census.blockgroups_2020 AS cbg 
ON 
  ST_Intersects(a.geog, cbg.geog)
JOIN 
  census.population_2020 AS cp 
ON 
  '1500000US' || cbg.geoid = cp.geoid
WHERE 
  a.mapname = 'University City'
AND 
  cp.total < 100;
