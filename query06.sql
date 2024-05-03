/*What are the top five neighborhoods according to your accessibility metric?*/

WITH accessible_stops AS (
    SELECT
        bs.stop_id,
        bs.stop_name,
        bs.parent_station,
        bs.wheelchair_boarding,
        bs.geog,
        nhoods.name AS neighborhood_name
    FROM septa.bus_stops AS bs
    LEFT JOIN azavea.neighborhoods AS nhoods ON ST_INTERSECTS(nhoods.geog, bs.geog)
    WHERE bs.wheelchair_boarding = 1 OR (bs.wheelchair_boarding = 0 AND bs.parent_station IS NOT NULL)
),
neighborhood_stats AS (
    SELECT
        n.name AS neighborhood_name,
        COUNT(DISTINCT bs.stop_id) AS total_stops,
        COUNT(DISTINCT CASE WHEN bs.wheelchair_boarding = 1 THEN bs.stop_id END) AS accessible_stops,
        ST_AREA(n.geog) AS shape_area
    FROM azavea.neighborhoods AS n
    LEFT JOIN septa.bus_stops AS bs ON ST_INTERSECTS(n.geog, bs.geog)
    GROUP BY n.name, n.geog
),
ranked_nhoods AS (
    SELECT
        ns.neighborhood_name,
        CASE WHEN ns.total_stops > 0 THEN ns.accessible_stops::numeric / ns.total_stops ELSE 0 END AS accessibility_metric,
        ns.accessible_stops AS num_bus_stops_accessible,
        (ns.total_stops - ns.accessible_stops) AS num_bus_stops_inaccessible
    FROM neighborhood_stats AS ns
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (ORDER BY accessibility_metric DESC) AS accessibility_rank
    FROM ranked_nhoods
    LIMIT 5 -- Limit to the top 5 neighborhoods
) AS ranked_nhoods_with_rank;