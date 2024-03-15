WITH wheelchair_accessible_stops AS (
    SELECT
        n.name AS neighborhood_name,
        COUNT(bs.stop_id) AS num_bus_stops_accessible
    FROM
        azavea.neighborhoods n
    LEFT JOIN
        septa.bus_stops bs
    ON
        ST_Within(ST_SetSRID(bs.geog::geometry, 4326), ST_SetSRID(n.geog::geometry, 4326))
    WHERE
        bs.wheelchair_boarding IN (1, 2)
    GROUP BY
        n.name
),

total_bus_stops AS (
    SELECT
        n.name AS neighborhood_name,
        COUNT(bs.stop_id) AS num_bus_stops_total
    FROM
        azavea.neighborhoods n
    LEFT JOIN
        septa.bus_stops bs
    ON
        ST_Within(ST_SetSRID(bs.geog::geometry, 4326), ST_SetSRID(n.geog::geometry, 4326))
    GROUP BY
        n.name
)

SELECT
    ws.neighborhood_name AS neighborhood_name,
    CASE
        WHEN ws.num_bus_stops_accessible >= 100 THEN 'High'
        WHEN ws.num_bus_stops_accessible >= 50 THEN 'Medium'
        ELSE 'Low'
    END AS accessibility_metric,
    ws.num_bus_stops_accessible AS num_bus_stops_accessible,
    ts.num_bus_stops_total - ws.num_bus_stops_accessible AS num_bus_stops_inaccessible
FROM
    wheelchair_accessible_stops ws
JOIN
    total_bus_stops ts
ON
    ws.neighborhood_name = ts.neighborhood_name
ORDER BY
    num_bus_stops_accessible ASC
LIMIT 5;
