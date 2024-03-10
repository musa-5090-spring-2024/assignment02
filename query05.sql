-- Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

WITH
summary AS (
    SELECT
        neighborhoods.listname AS neighborhood,
        neighborhoods.geog AS neighborhood_geog,
        bus.geog AS bus_geog,
        SUM(bus.wheelchair_boarding) AS accessibility
    FROM septa.bus_stops AS bus
    INNER JOIN azavea.neighborhoods AS neighborhoods
        ON ST_COVERS(neighborhoods.geog, bus.geog)
    GROUP BY neighborhood, neighborhood_geog, bus.geog
)

SELECT
    summary.neighborhood,
    SUM(summary.accessibility) AS accessibility
FROM summary
GROUP BY summary.neighborhood, accessibility
ORDER BY accessibility DESC
