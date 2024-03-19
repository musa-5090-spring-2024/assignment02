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
    ORDER BY accessibility_metric DESC, num_bus_stops_accessible DESC 
    LIMIT 5;




















WITH neighborhood_stops AS (
    SELECT 
        neighborhoods.listname AS neighborhood_name,
        COUNT(*) FILTER (WHERE bus_stops.wheelchair_boarding = 1) AS num_bus_stops_accessible,
        COUNT(*) FILTER (WHERE bus_stops.wheelchair_boarding = 2) AS num_bus_stops_inaccessible
    FROM azavea.neighborhoods
    JOIN septa.bus_stops ON ST_Contains(neighborhoods.geog, ST_SetSRID(ST_MakePoint(bus_stops.stop_lon, bus_stops.stop_lat), 4326))
    GROUP BY neighborhoods.listname
),

accessibility_metrics AS (
    SELECT 
        neighborhood_name,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible,
        CASE 
            WHEN num_bus_stops_accessible + num_bus_stops_inaccessible = 0 THEN 0
            ELSE num_bus_stops_accessible::float / (num_bus_stops_accessible + num_bus_stops_inaccessible)
        END AS accessibility_metric
    FROM neighborhood_stops
)

SELECT * FROM accessibility_metrics ORDER BY accessibility_metric DESC LIMIT 5;
SELECT * FROM accessibility_metrics ORDER BY accessibility_metric ASC LIMIT 5;