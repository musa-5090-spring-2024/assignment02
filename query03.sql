CREATE INDEX idx_parcels_geog ON phl.pwd_parcels USING GIST(geog);
CREATE INDEX idx_bus_stops_geog ON septa.bus_stops USING GIST(geog);

SELECT
    parcels.address,
    stops.stop_name,
    ROUND(ST_Distance(parcels.geog, stops.geog)::numeric, 2) AS distance
FROM
    phl.pwd_parcels AS parcels
CROSS JOIN LATERAL
    (SELECT 
        stop_name, 
        geog,
        parcels.geog <-> geog AS distance
     FROM 
        septa.bus_stops
     ORDER BY 
        parcels.geog <-> geog
     LIMIT 1) AS stops
ORDER BY distance DESC;