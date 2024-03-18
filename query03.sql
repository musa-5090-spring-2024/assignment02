/* Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).

(
    parcel_address text,  -- The address of the parcel
    stop_name text,  -- The name of the bus stop
    distance double precision  -- The distance apart in meters
)
*/

select
	pwd_parcels.address as parcel_address,
	nearest_bus_stop.stop_name,
	st_distance(nearest_bus_stop.geog, pwd_parcels.geog) as distance
from phl.pwd_parcels
cross join lateral (
	select *
	from septa.bus_stops as bus_stops
	order by pwd_parcels.geog <-> bus_stops.geog
	limit 1
) as nearest_bus_stop
order by distance desc;