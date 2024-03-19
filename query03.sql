/*
Using the Philadelphia Water Department Stormwater Billing 
Parcels dataset, pair each parcel with its closest bus stop. 
The final result should give the parcel address, bus stop 
name, and distance apart in meters, rounded to two decimals. 
Order by distance (largest on top).
*/

/* CREATE INDEX IF NOT EXISTS bus_stops_geog_idx
    ON septa.bus_stops USING gist
    ( (ST_MakePoint(stop_lon, stop_lat)::geography) )
    TABLESPACE pg_default;
*/
WITH
septa_bus_stops AS (
    SELECT
        stop_name,
        st_makepoint(stop_lon, stop_lat)::geography as geog
    FROM septa.bus_stops
),

parcel_stop_distances AS (
    SELECT
        pwd_parcels.address::text AS parcel_address,
        pwd_parcels.geog,
        nearest_bus_stop.stop_name AS stop_name,
        ST_DISTANCE(pwd_parcels.geog::geography, 
        nearest_bus_stop.geog::geography) AS distance
    FROM phl.pwd_parcels
    CROSS JOIN LATERAL (
        SELECT *
        FROM septa_bus_stops AS bus_stops
        ORDER BY pwd_parcels.geog <-> bus_stops.geog
        LIMIT 1
    ) AS nearest_bus_stop
)

SELECT
    parcel_address,
    stop_name,
    ROUND(CAST(distance AS numeric), 2) AS distance
FROM parcel_stop_distances
ORDER BY distance DESC;