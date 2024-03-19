/* Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top). */

SELECT
    parcel.address AS parcel_address,
    stop.stop_name,
    ROUND(CAST(ST_Distance(parcel.geog, stop.geog) AS numeric), 2) as distance
    from phl.pwd_parcels as parcel
    CROSS JOIN LATERAL
    (SELECT
    stop.stop_name,
    stop.geog
    from septa.bus_stops as stop
    ORDER BY stop.geog <-> parcel.geog
    Limit 1) as stop
    ORDER BY distance DESC

    
    