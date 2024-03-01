/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.
*/

with shapes as (
    select
        shape_id,
        st_makeline(array_agg(st_makepoint(shape_pt_lon, shape_pt_lat) order by shape_pt_sequence))::geography as shape_geog
    from septa.bus_shapes
    group by shape_id
),

routes as (
    select distinct
        bus_trips.shape_id,
        bus_trips.route_id,
        bus_trips.trip_headsign,
        bus_routes.route_short_name
    from septa.bus_trips
    inner join septa.bus_routes
        on bus_trips.route_id = bus_routes.route_id
    order by bus_trips.shape_id
)

select
    routes.route_short_name,
    routes.trip_headsign,
    shapes.shape_geog,
    round(st_length(shapes.shape_geog)::numeric, 0) as shape_length
from shapes
inner join routes
    on shapes.shape_id = routes.shape_id
order by shape_length desc
limit 2
