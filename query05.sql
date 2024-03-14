-- Active: 1709164238938@@127.0.0.1@5432@musa509a2
/*
Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly
 along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity 
 in the metric you devise in rating neighborhoods.

NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case.

Discuss your accessibility metric and how you arrived at it below:

Description:
*/

WITH AccessibleStops AS (
    SELECT
        n.name,
        COUNT(s.stop_id) AS total_stops,
        SUM(CASE WHEN s.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS accessible_stops
    FROM
        septa.bus_stops s
    JOIN
        azavea.neighborhoods n ON ST_Contains(n.geog::geometry, ST_SetSRID(ST_Point(s.stop_lon, s.stop_lat), 4326))
    GROUP BY
        n.name
),
Density AS (
    SELECT
        a.name,
        (a.accessible_stops / ST_Area(n.geog::geometry)) AS density_accessible_stops
    FROM
        AccessibleStops a
    JOIN
        azavea.neighborhoods n ON a.name = n.name
)
SELECT
    a.name,
    (0.7 * (a.accessible_stops / NULLIF(a.total_stops, 0)) + 0.3 * d.density_accessible_stops) AS accessibility_score
FROM
    AccessibleStops a
JOIN
    Density d ON a.name = d.name
ORDER BY
    accessibility_score DESC;


