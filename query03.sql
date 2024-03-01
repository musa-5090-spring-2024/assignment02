/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name,
and distance apart in meters, rounded to two decimals. Order by distance (largest on top).
*/

with t1 as (select
    pwd_parcels.address as parcel_address,
    nearest_bus_stop.stop_name,
    pwd_parcels.geog as parcel_geog,
    nearest_bus_stop.geog as bus_geog
from phl.pwd_parcels
cross join lateral (
    select
        bus_stops.stop_name,
        bus_stops.geog
    from septa.bus_stops as bus_stops
    order by pwd_parcels.geog <-> bus_stops.geog
    limit 1
) as nearest_bus_stop)

select
    parcel_address,
    stop_name,
	round(st_distance(parcel_geog,bus_geog)::numeric,2) as distance
from t1
order by distance desc
