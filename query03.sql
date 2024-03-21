Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).

Your query should run in under two minutes.

_HINT: This is a nearest neighbor problem.

(
    parcel_address text,  -- The address of the parcel
    stop_name text,  -- The name of the bus stop
    distance numeric  -- The distance apart in meters, rounded to two decimals
)