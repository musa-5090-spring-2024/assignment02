/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. 
The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. 
Order by distance (largest on top).

Your query should run in under two minutes.

_HINT: This is a nearest neighbor problem.
*/

SELECT
    p.address::text AS parcel_address,
    b.stop_name::text AS stop_name,
    ROUND(ST_Distance(p.geog::geometry, b.geog::geometry)::numeric, 2) AS distance
FROM
    septa.bus_stops AS b
CROSS JOIN LATERAL (
    SELECT
        p.address,
        p.geog
    FROM
        phl.pwd_parcels AS p
    ORDER BY
        p.geog <-> b.geog
    LIMIT 1
) p;


