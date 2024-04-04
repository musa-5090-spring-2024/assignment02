SELECT
    n.name AS neighborhood_name,
    -- Replace null with 0 for accessibility_metric using COALESCE
    COALESCE(ROUND(((COUNT(bs.stop_id) FILTER (WHERE bs.wheelchair_boarding = 1)::decimal / NULLIF(COUNT(bs.stop_id), 0)) * COUNT(bs.stop_id))::numeric, 2), 0) AS accessibility_metric,
    COUNT(bs.stop_id) FILTER (WHERE bs.wheelchair_boarding = 1) AS num_bus_stops_accessible,
    COUNT(bs.stop_id) FILTER (WHERE bs.wheelchair_boarding != 1 AND bs.wheelchair_boarding IS NOT NULL) AS num_bus_stops_inaccessible
FROM
    azavea.neighborhoods AS n
LEFT JOIN
    septa.bus_stops AS bs ON ST_CONTAINS(n.geog::geometry, bs.geog::geometry)
GROUP BY
    n.name
ORDER BY
    accessibility_metric DESC;
