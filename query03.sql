-- Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).

-- Your query should run in under two minutes.


SELECT
    pwd_parcels.address AS parcel_address,
    nearest_bus_stop.stop_name,
    nearest_bus_stop.distance
FROM phl.pwd_parcels
CROSS JOIN LATERAL (
    SELECT
        *,
        ROUND(cast(pwd_parcels.geog <-> stops.geog AS NUMERIC), 2) AS distance
    FROM septa.bus_stops AS stops
    ORDER BY pwd_parcels.geog <-> stops.geog
    LIMIT 1
) AS nearest_bus_stop
ORDER BY nearest_bus_stop.distance DESC
