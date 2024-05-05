WITH neighborhood_metrics AS (
    SELECT
        neighborhood_name,
        COUNT(*) AS total_stops,
        SUM(CASE WHEN wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS accessible_stops,
        SUM(CASE WHEN wheelchair_boarding = 2 OR wheelchair_boarding = 0 THEN 1 ELSE 0 END) AS inaccessible_stops
    FROM
        septa_bus_stops
    GROUP BY
        neighborhood_name
)
SELECT
    nm.neighborhood_name,
    ROUND(COALESCE(nm.accessible_stops::numeric / NULLIF(nm.total_stops, 0), 0), 2) AS accessibility_metric,
    nm.accessible_stops AS num_bus_stops_accessible,
    nm.inaccessible_stops AS num_bus_stops_inaccessible
FROM
    neighborhood_metrics nm
ORDER BY
    accessibility_metric DESC
LIMIT 5;
