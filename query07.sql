WITH wheelchair_accessible_stops AS (
  SELECT DISTINCT ON (geog) geog
  FROM septa.bus_stops
  WHERE wheelchair_boarding = 1
),
unique_block_groups_near_stops AS (
  SELECT DISTINCT cbg.geoid
  FROM census.blockgroups_2020 AS cbg
  JOIN wheelchair_accessible_stops AS was
  ON ST_DWithin(cbg.geog::geography, was.geog, 100)
),
populated_block_groups AS (
  SELECT 
    ubgns.geoid, 
    SUM(cp.total) AS total_population
  FROM unique_block_groups_near_stops AS ubgns
  JOIN census.population_2020 AS cp 
  ON '1500000US' || ubgns.geoid = cp.geoid
  GROUP BY ubgns.geoid
),
neighborhood_populations AS (
  SELECT 
    a.mapname, 
    SUM(pbg.total_population) AS total_population
  FROM azavea.neighborhoods AS a
  JOIN populated_block_groups AS pbg
  ON ST_Intersects(a.geog, (SELECT geog FROM census.blockgroups_2020 WHERE geoid = pbg.geoid))
  GROUP BY a.mapname
  ORDER BY 
  total_population ASC
  LIMIT 5
)
SELECT * FROM neighborhood_populations;
