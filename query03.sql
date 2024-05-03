--Question 3
--Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. 
--The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).
--the code should use the nearest neighbour function and the query should run in under two minutes 

WITH closest_bus_stop AS (
    SELECT
        phl.address AS parcel_address,
        stops.stop_name,
        stops.stop_id,
        (ST_Distance(phl.geog, stops.geog)) AS distance
    FROM
        phl.pwd_parcels AS phl
    CROSS JOIN LATERAL (
        SELECT
            stop_id,
            stop_name,
            geog
        FROM
            septa.bus_stops
        ORDER BY
            phl.geog <-> septa.bus_stops.geog
        LIMIT 1
    ) AS stops
)
SELECT
    parcel_address::text,
    stop_name,
    distance
FROM
    closest_bus_stop
ORDER BY
    distance desc