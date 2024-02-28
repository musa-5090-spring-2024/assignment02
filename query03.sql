/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
pair each parcel with its closest bus stop. The final result should give the 
parcel address, bus stop name, and distance apart in meters. Order by distance 
(largest on top).

    _Your query should run in under two minutes._

    >_**HINT**: This is a [nearest neighbor]
    (https://postgis.net/workshops/postgis-intro/knn.html) problem.

    **Structure:**
    ```sql
    (
        parcel_address text,  -- The address of the parcel
        stop_name text,  -- The name of the bus stop
        distance double precision  -- The distance apart in meters
    )
*/

/*with water as(
    select
        address,
        geog::geometry as geom
    from phl.pwd_parcels
)*/

select 
    water.address as parcel_address,
    stops.stop_name as stop_name,
    round(st_distance(stops.geog, water.geog)::numeric, 2) as distance
from phl.pwd_parcels as water
cross join lateral (
    select stops.stop_name, stops.geog, stops.geog <-> water.geog as distance
    from septa.bus_stops as stops
    order by distance
    limit 1
) stops
order by distance desc;