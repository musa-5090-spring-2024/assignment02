/* What are the top five neighborhoods according to your accessibility metric? */

SELECT
    neighborhoods.name AS neighborhood_name,
    SUM(CASE WHEN bus_stops.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible,
    SUM(CASE WHEN bus_stops.wheelchair_boarding != 1 THEN 1 ELSE 0 END) AS num_bus_stops_inaccessible,
    (SUM(CASE WHEN bus_stops.wheelchair_boarding = 1 THEN 1 ELSE 0 END) / (ST_Area(neighborhoods.geog::geography) / 1000000)) AS accessibility_metric
FROM
    azavea.neighborhoods
JOIN
    septa.bus_stops
ON
    ST_Within(bus_stops.geog::geometry, neighborhoods.geog::geometry)
GROUP BY
    neighborhoods.name,
    neighborhoods.geog
ORDER BY
    accessibility_metric DESC
LIMIT 5;
