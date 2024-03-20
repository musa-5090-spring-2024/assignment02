-- Q6:
-- Assign neighborhoods to bus stops
ALTER TABLE septa.bus_stops
ADD COLUMN neighborhood_name TEXT;
UPDATE septa.bus_stops
SET neighborhood_name = azavea.neighborhoods.name
FROM azavea.neighborhoods
WHERE ST_Contains(azavea.neighborhoods.geog::geometry, septa.bus_stops.geog::geometry);

WITH enhanced_stops AS (
    SELECT
        bs.stop_id,
        bs.stop_name,
        bs.geog,
        bs.parent_station,
        bs.neighborhood_name,
        CASE
            WHEN bs.wheelchair_boarding != 0 THEN bs.wheelchair_boarding
            ELSE COALESCE(parent.wheelchair_boarding, 0)
        END AS new_wheelchair_boarding
    FROM
        septa.bus_stops bs
    LEFT JOIN
        septa.bus_stops parent ON bs.parent_station = parent.stop_id
)

SELECT
    n.name,
    ROUND(
        SUM(CASE WHEN es.new_wheelchair_boarding = 1 THEN 1 ELSE 0 END) / 
        (CAST(n.shape_area AS NUMERIC) / 27878400), 2
    ) AS accessibility_metric,
    SUM(CASE WHEN es.new_wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible,
    SUM(CASE WHEN es.new_wheelchair_boarding = 2 OR es.new_wheelchair_boarding = 0 THEN 1 ELSE 0 END) AS num_bus_stops_inaccessible
FROM
    enhanced_stops es
JOIN
    azavea.neighborhoods n ON es.neighborhood_name = n.name
GROUP BY
    n.name, n.shape_area
ORDER BY
    accessibility_metric DESC
LIMIT 5;
