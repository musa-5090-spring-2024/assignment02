/*What are the bottom five neighborhoods according to your accessibility metric?*/

WITH neighborhood_stops AS (
    SELECT
        n.neighborhood_name,
        ST_Area(n.geog::geography) / 1000000 AS area_sq_km, -- Convert area from square meters to square kilometers
        COUNT(*) FILTER (WHERE b.wheelchair_boarding = 1) AS num_bus_stops_accessible,
        COUNT(*) FILTER (WHERE b.wheelchair_boarding != 1 OR b.wheelchair_boarding IS NULL) AS num_bus_stops_inaccessible
    FROM azavea.neighborhoods n
    JOIN septa.bus_stops b ON ST_Contains(n.geog, b.geog)
    GROUP BY n.neighborhood_name
),
accessibility_metric AS (
    SELECT
        neighborhood_name,
        area_sq_km,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible,
        (num_bus_stops_accessible / NULLIF(area_sq_km, 0)) AS accessibility_metric 
    FROM neighborhood_stops
)
SELECT
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM accessibility_metric
ORDER BY accessibility_metric ASC, num_bus_stops_accessible ASC 
LIMIT 5;
