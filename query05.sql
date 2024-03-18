/* Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case.

Discuss your accessibility metric and how you arrived at it below:

Description:
*/

select
    accessible.name as neighborhood_name,
    accessible.num / neigh_area as accessibility_metric,
    accessible.num as num_bus_stops_accessible,
    inaccessible.num as num_bus_stops_inaccessible
from
    (SELECT 
        neighborhoods.name,
        COUNT (1) as num,
        st_area(neighborhoods.geog::geography)/1000000 as neigh_area
    from 
        azavea.neighborhoods
	join 
		septa.bus_stops
	on 
		st_within(septa.bus_stops.geog::geometry, azavea.neighborhoods.geog::geometry)
	where wheelchair_boarding = 1
	group by
		neighborhoods.name, neighborhoods.geog) 
as accessible

join

	(SELECT  -- noqa
		neighborhoods.name,
		COUNT (1) as num
	from 
		azavea.neighborhoods
	join 
		septa.bus_stops
	on 
		st_within(septa.bus_stops.geog::geometry, azavea.neighborhoods.geog::geometry)
	where wheelchair_boarding != 1
	group by
		neighborhoods.name) 
as inaccessible
	
on accessible.name = inaccessible.name