WITH wheelchair_accessible_stops AS (
  SELECT geog, wheelchair_boarding
  FROM septa.bus_stops
  WHERE wheelchair_boarding = 1
  UNION ALL
  SELECT geog, wheelchair_boarding
  FROM septa.bus_stops
  WHERE wheelchair_boarding = 0
),
block_groups_near_stops AS (
  SELECT DISTINCT cbg.geoid
  FROM census.blockgroups_2020 AS cbg
  JOIN wheelchair_accessible_stops AS was
  ON ST_DWithin(cbg.geog::geography, was.geog, 100)
),
populated_block_groups AS (
  SELECT 
    bgn.geoid, 
    SUM(cp.total) AS total_population
  FROM block_groups_near_stops AS bgn
  JOIN census.population_2020 AS cp 
  ON '1500000US' || bgn.geoid = cp.geoid
  GROUP BY bgn.geoid
),
neighborhood_stop_counts AS (
  SELECT
    a.mapname,
    SUM(CASE WHEN was.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible,
    SUM(CASE WHEN was.wheelchair_boarding = 0 THEN 1 ELSE 0 END) AS num_bus_stops_inaccessible
  FROM azavea.neighborhoods AS a
  JOIN wheelchair_accessible_stops AS was
  ON ST_DWithin(a.geog, was.geog::geography, 100)
  GROUP BY a.mapname
),
neighborhood_populations AS (
  SELECT 
    a.mapname, 
    SUM(pbg.total_population) AS total_population
  FROM azavea.neighborhoods AS a
  JOIN populated_block_groups AS pbg
  ON ST_Intersects(a.geog, (SELECT geog FROM census.blockgroups_2020 WHERE geoid = pbg.geoid))
  GROUP BY a.mapname
),
population_stats AS (
  SELECT
    AVG(total_population) AS avg_population,
    STDDEV_POP(total_population) AS stddev_population
  FROM neighborhood_populations
),
neighborhood_accessibility AS (
  SELECT 
    np.mapname AS neighborhood_name,
    (np.total_population - ps.avg_population) / ps.stddev_population AS accessibility_metric,
    nsc.num_bus_stops_accessible,
    nsc.num_bus_stops_inaccessible
  FROM neighborhood_populations np
  CROSS JOIN population_stats ps
  JOIN neighborhood_stop_counts nsc ON np.mapname = nsc.mapname
  ORDER BY
  accessibility_metric DESC
  LIMIT 5
)
SELECT * FROM neighborhood_accessibility;
