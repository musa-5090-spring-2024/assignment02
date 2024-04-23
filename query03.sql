/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
  pair each parcel with its closest bus stop. The final result should give the parcel address, 
  bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).
*/


CREATE INDEX IF NOT EXISTS idx_parcels_geog ON phl.pwd_parcels USING GIST(geog);
CREATE INDEX IF NOT EXISTS idx_bus_stops_geog ON septa.bus_stops USING GIST(geog);

SELECT
    parcels.address AS parcel_address,
    stops.stop_name,
    ROUND(ST_Distance(parcels.geog, stops.geog)::numeric, 2) AS distance
FROM
    phl.pwd_parcels AS parcels
CROSS JOIN LATERAL
    (SELECT 
        stop_name, 
        geog
     FROM 
        septa.bus_stops
     ORDER BY 
        parcels.geog <-> geog
     LIMIT 1) AS stops
ORDER BY distance DESC;



