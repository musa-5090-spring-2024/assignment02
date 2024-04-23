/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs. 
  Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset 
  from the Septa GTFS bus feed. Use the GTFS documentation for help. 
  Use some creativity in the metric you devise in rating neighborhoods.
*/

WITH stops_info AS (
    SELECT
        n.name AS neighborhood_name,
        ST_Area(n.geog::geography) / 1000000 AS area_sq_km, -- Convert area from sq meters to sq kilometers
        COUNT(bs.stop_id) FILTER (WHERE bs.wheelchair_boarding = 1) AS num_accessible_stops,
        COUNT(bs.stop_id) AS total_stops
    FROM azavea.neighborhoods AS n
    LEFT JOIN septa.bus_stops AS bs
        ON ST_Contains(n.geog, bs.geog)
    GROUP BY n.name, n.geog
),
accessibility_metrics AS (
    SELECT
        neighborhood_name,
        num_accessible_stops,
        total_stops,
        area_sq_km,
        ROUND((num_accessible_stops / NULLIF(total_stops, 0))::numeric, 2) AS proportion_accessible,
        ROUND((num_accessible_stops / NULLIF(area_sq_km, 0))::numeric, 2) AS accessible_density
    FROM stops_info
)
SELECT
    neighborhood_name,
    accessible_density,
    proportion_accessible,
    num_accessible_stops,
    total_stops - num_accessible_stops AS num_non_accessible_stops
FROM accessibility_metrics
ORDER BY accessible_density DESC, proportion_accessible DESC;





