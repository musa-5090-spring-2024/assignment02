/* What are the bottom five neighborhoods according to your accessibility metric? 

Both #6 and #7 should have the structure:
(
  neighborhood_name text,  -- The name of the neighborhood
  accessibility_metric ...,  -- Your accessibility metric value
  num_bus_stops_accessible integer,
  num_bus_stops_inaccessible integer
)
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

order by accessibility_metric asc
limit 5;