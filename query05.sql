-- Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

SELECT
    neighborhoods.listname::TEXT AS neighborhood_name,
    COALESCE(SUM(bus.wheelchair_boarding), 0)::INTEGER AS accessibility_metric,
    SUM(CASE WHEN bus.wheelchair_boarding != 0 THEN 1 ELSE 0 END)::INTEGER AS num_bus_stops_accessible,
    SUM(CASE WHEN bus.wheelchair_boarding = 0 THEN 1 ELSE 0 END)::INTEGER AS num_bus_stops_inaccessible
FROM septa.bus_stops AS bus
RIGHT JOIN azavea.neighborhoods AS neighborhoods -- noqa: cv08
    ON ST_COVERS(neighborhoods.geog, bus.geog)
GROUP BY neighborhood_name
ORDER BY accessibility_metric DESC
