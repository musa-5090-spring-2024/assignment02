/* What are the top five neighborhoods according to your accessibility metric? */

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

	(SELECT 
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

order by accessibility_metric desc
limit 5;