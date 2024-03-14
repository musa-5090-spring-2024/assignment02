-- Active: 1709164238938@@127.0.0.1@5432@musa509a2
/*
What are the bottom five neighborhoods according to your accessibility metric?
*/

WITH AccessibilityData AS (
    SELECT
        n.name AS neighborhood_name,
        COUNT(s.stop_id) FILTER (WHERE s.wheelchair_boarding = 1) AS num_bus_stops_accessible,
        COUNT(s.stop_id) FILTER (WHERE s.wheelchair_boarding = 0 OR s.wheelchair_boarding IS NULL) AS num_bus_stops_inaccessible
    FROM
        septa.bus_stops s
    JOIN
        azavea.neighborhoods n ON ST_Contains(n.geog::geometry, ST_SetSRID(ST_MakePoint(s.stop_lon, s.stop_lat), 4326))
    GROUP BY
        n.name
),
AccessibilityMetric AS (
    SELECT
        ad.neighborhood_name,
        (0.7 * (num_bus_stops_accessible::FLOAT / NULLIF(num_bus_stops_accessible + num_bus_stops_inaccessible, 0)) +
        0.3 * (num_bus_stops_accessible / NULLIF(ST_Area(n.geog::geometry), 0))) AS accessibility_score, -- Assuming ST_Area returns sq. km or unit is converted accordingly.
        num_bus_stops_accessible,
        num_bus_stops_inaccessible
    FROM
        AccessibilityData ad
    JOIN
        azavea.neighborhoods n ON ad.neighborhood_name = n.name
)
SELECT
    neighborhood_name,
    accessibility_score,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM
    AccessibilityMetric
WHERE
    accessibility_score IS NOT NULL
ORDER BY
    accessibility_score ASC
LIMIT 5;






