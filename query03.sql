SELECT parcels.address AS parcel_address,
       parcel_to_stop.stop_name AS stop_name,
       ROUND(ST_DISTANCE(parcel_to_stop.geog, parcels.geog)::numeric,2) AS distance
FROM phl.pwd_parcels AS parcels
CROSS JOIN LATERAL (
  SELECT *
  FROM septa.bus_stops AS bus_stops
  ORDER BY bus_stops.geog <-> parcels.geog
  LIMIT 1
) AS parcel_to_stop
ORDER BY 
    distance DESC;