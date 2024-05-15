5.  Rate neighborhoods by their bus stop accessibility for wheelchairs. 
Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods.

    _NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case._

    Discuss your accessibility metric and how you arrived at it below:

WITH accessible_stops AS (
    SELECT
        ns.neighborhood_id,
        COUNT(CASE WHEN bs.wheelchair_accessible = 1 THEN bs.stop_id END) AS num_accessible_stops,
        COUNT(bs.stop_id) AS total_stops,
        AVG(ST_Distance(ns.geom, bs.geom)) AS avg_distance_to_accessible_stop
    FROM
        neighborhoods AS ns
    LEFT JOIN
        bus_stops AS bs ON ST_DWithin(ns.geom, bs.geom, 500) 
    GROUP BY
        ns.neighborhood_id
),
accessible_routes AS (
    SELECT
        ns.neighborhood_id,
        COUNT(DISTINCT CASE WHEN bt.wheelchair_accessible = 1 THEN bt.route_id END) AS num_accessible_routes
    FROM
        neighborhoods AS ns
    LEFT JOIN
        bus_trips AS bt ON ST_DWithin(ns.geom, bt.geom, 500) 
    GROUP BY
        ns.neighborhood_id
),
neighborhood_accessibility AS (
    SELECT
        ns.neighborhood_id,
        COALESCE(as.num_accessible_stops, 0) AS num_accessible_stops,
        COALESCE(as.total_stops, 0) AS total_stops,
        COALESCE(as.avg_distance_to_accessible_stop, 0) AS avg_distance_to_accessible_stop,
        COALESCE(ar.num_accessible_routes, 0) AS num_accessible_routes
    FROM
        neighborhoods AS ns
    LEFT JOIN
        accessible_stops AS as ON ns.neighborhood_id = as.neighborhood_id
    LEFT JOIN
        accessible_routes AS ar ON ns.neighborhood_id = ar.neighborhood_id
)
SELECT
    ns.neighborhood_id,
    ns.neighborhood_name,
    (num_accessible_stops::numeric / total_stops) * 100 AS percent_accessible_stops,
    100 - (avg_distance_to_accessible_stop / 500) * 100 AS proximity_score, 
    num_accessible_routes AS num_accessible_routes
FROM
    neighborhoods AS ns
JOIN
    neighborhood_accessibility AS na ON ns.neighborhood_id = na.neighborhood_id
ORDER BY
    percent_accessible_stops DESC, proximity_score DESC, num_accessible_routes DESC;

