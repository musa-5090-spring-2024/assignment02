-- Calculate accessibility metric for each neighborhood
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

-- Calculate accessibility ratio
SELECT
    nm.neighborhood_name,
    ROUND(COALESCE(nm.accessible_stops::numeric / NULLIF(nm.total_stops, 0), 0), 2) AS accessibility_ratio,
    nm.accessible_stops,
    nm.inaccessible_stops,
    nm.total_stops
FROM
    neighborhood_metrics nm
ORDER BY
    accessibility_ratio DESC;
--This metric provides a simple and effective way to rate neighborhoods by their wheelchair accessibility based on bus stop infrastructure. By considering both accessible and inaccessible stops within each neighborhood, it offers a comprehensive view of the wheelchair accessibility level.
