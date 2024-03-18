/* Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, 
find the two routes with the longest trips.
Your query should run in under two minutes.

(
    route_short_name text,  -- The short name of the route
    trip_headsign text,  -- Headsign of the trip
    shape_geog geography,  -- The shape of the trip
    shape_length double precision  -- Length of the trip in meters
)

*/

select 
	trip_route.route_id as route_short_name,
    trip_route.trip_headsign as trip_headsign,
    line_length.geog as shape_geog,
    line_length.length as shape_length
	
from 
	(select 
		shape_id,
	 	ST_MakeLine(array_agg(
			ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) order by shape_pt_sequence)) as geog,
		st_length(
			ST_MakeLine(array_agg(
				ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) order by shape_pt_sequence))
			::geography) as length
	from septa.bus_shapes
	group by shape_id) as line_length

join

	(select 
			route_id, 
			trip_headsign, 
			shape_id
		from septa.bus_trips
		group by route_id, trip_headsign, shape_id
	) as trip_route

on trip_route.shape_id = line_length.shape_id
order by shape_length desc
limit 2;
