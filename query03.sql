/*
3.  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).

    _Your query should run in under two minutes._

    >_**HINT**: This is a [nearest neighbor](https://postgis.net/workshops/postgis-intro/knn.html) problem.

    **Structure:**
    ```sql
    (
        parcel_address text,  -- The address of the parcel
        stop_name text,  -- The name of the bus stop
        distance double precision  -- The distance apart in meters
    )
    ```
*/


SELECT
    p.address,
    bs.stop_name,
    ST_Distance(p.geog, bs.geog) AS distance
FROM
    phl.pwd_parcels AS p
CROSS JOIN LATERAL
    (
        SELECT
            bs.stop_name,
            bs.geog
        FROM septa.bus_stops AS bs
        ORDER BY p.geog <-> bs.geog
        LIMIT 1
    ) AS bs
ORDER BY distance DESC
