WITH wheelchair_stops_count AS (
    SELECT
        neighborhood.cartodb_id AS neighborhood_id,
        neighborhood.listname AS neighborhood_name,
        COUNT(*) AS total_stops,
        SUM(CASE WHEN stops.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible
    FROM
        azavea.neighborhoods neighborhood
    INNER JOIN
        septa.bus_stops stops ON ST_Intersects(neighborhood.geog, stops.geog)
    GROUP BY
        neighborhood.cartodb_id, neighborhood.listname
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
), 
final_result AS (
    SELECT
        neighborhood_name,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible,
        accessibility_metric
    FROM
        neighborhood_accessibility
    ORDER BY
        accessibility_metric DESC, num_bus_stops_accessible DESC
    LIMIT 5
)
SELECT * FROM final_result;