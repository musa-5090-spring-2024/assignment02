/*Rate neighborhoods by their bus stop accessibility for wheelchairs. 
Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the 
Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you 
devise in rating neighborhoods.

NOTE: There is no automated test for this question, as there's no one right answer. With urban data 
analysis, this is frequently the case.
*/


/*Discuss your accessibility metric and how you arrived at it below:

Description: I used the wheelchair_boarding field in the septa.bus_stops table to measure wheelchair
accessibility on bus stops. I decided to combine this with a spatial attribute to understand
where septa may be lacking wheelchair accessible bus stops or if there are certain neighborhoods
that benefit from this asset in comparison to others. I did this by analyzing the density of wheelchair 
accessible bus stops by neighborhood. If I were to take this analysis a step further, I'd look at how
this density aligns with the age of the population, as older individuals are more likely to need a
wheelchair accessible bus stop. 

*/

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
SELECT * FROM ranked_nhoods
ORDER BY accessibility_metric DESC;
