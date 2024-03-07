SELECT 
  a.mapname, 
  SUM(cp.total) AS total_population
FROM 
  azavea.neighborhoods AS a
JOIN 
  septa.bus_stops AS bs 
ON 
  ST_DWithin(a.geog, bs.geog::geography, 100)
JOIN 
  census.blockgroups_2020 AS cbg 
ON 
  ST_Intersects(a.geog, cbg.geog)
JOIN 
  census.population_2020 AS cp 
ON 
  '1500000US' || cbg.geoid = cp.geoid
GROUP BY 
  a.mapname
ORDER BY 
  total_population DESC
LIMIT 5;
