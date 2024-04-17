/*
Rate neighborhoods by their bus stop accessibility for wheelchairs.
Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed.
Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

NOTE: There is no automated test for this question, as there's no one right answer. 
With urban data analysis, this is frequently the case.

What are the _top five_ neighborhoods according to your accessibility metric?
*/

WITH wheelchair_stops_count AS (
    SELECT
        n.cartodb_id AS neighborhood_id,
        n.listname AS neighborhood_name,
        COUNT(*) AS total_stops,
        SUM(CASE WHEN b.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible
    FROM
        azavea.neighborhoods n
    INNER JOIN
        septa.bus_stops b ON ST_Intersects(n.geog, b.geog)
    GROUP BY
        n.cartodb_id, n.listname
),
neighborhood_accessibility AS (
    SELECT
        neighborhood_id,
        neighborhood_name,
        total_stops,
        num_bus_stops_accessible,
        ROUND((num_bus_stops_accessible::numeric / total_stops) * 100, 1) AS accessibility_metric,
        (total_stops - num_bus_stops_accessible) AS num_bus_stops_inaccessible
    FROM
        wheelchair_stops_count
)
SELECT
    neighborhood_name,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible,
    accessibility_metric
FROM
    neighborhood_accessibility
ORDER BY
    accessibility_metric DESC, num_bus_stops_accessible DESC
LIMIT 5;