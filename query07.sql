/* Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's 
neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the 
Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the 
metric you devise in rating neighborhoods.

NOTE: There is no automated test for this question, as there's no one right answer. 
With urban data analysis, this is frequently the case. */

	
With
    stop_hood as (
        select 
        	hood.listname as neighborhood_name,
            COUNT(*) FILTER (WHERE stop.wheelchair_boarding = 1) AS num_bus_stops_accessible,
            COUNT(*) FILTER (WHERE stop.wheelchair_boarding = 2) AS num_bus_stops_inaccessible
        from azavea.neighborhoods as hood
        join septa.bus_stops as stop
            on ST_Covers(
                hood.geog, 
                ST_SETSRID(st_makepoint(stop.stop_lon, stop.stop_lat), 4326)::geography)
        GROUP BY hood.listname
    ),

accessibility_metrics AS (
    SELECT *,
        CASE 
            WHEN num_bus_stops_accessible + num_bus_stops_inaccessible = 0 THEN 0
            ELSE num_bus_stops_accessible::float / (num_bus_stops_accessible + num_bus_stops_inaccessible)
        END AS accessibility_metric
    FROM stop_hood
)

SELECT * 
    FROM accessibility_metrics 
    ORDER BY accessibility_metric ASC, num_bus_stops_accessible ASC 
    LIMIT 5;
