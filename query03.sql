SELECT parcels.address AS parcel_address,
       parcel_to_stop.stop_name AS stop_name,
       ROUND(ST_DISTANCE(parcel_to_stop.geom, parcels.geom)::numeric,2) AS distance
FROM phl_pwd_parcels AS parcels
CROSS JOIN LATERAL (
  SELECT *
  FROM septa_bus_stops AS bus_stops
  WHERE ST_DWithin(bus_stops.geom, parcels.geom, 1000)  -- Limit to parcels within 1000 meters
  ORDER BY bus_stops.geom <-> parcels.geom
  LIMIT 1
) AS parcel_to_stop
ORDER BY 
    distance DESC;

