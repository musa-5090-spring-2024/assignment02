SELECT 
	parcels.address AS parcel_address,
	stops.stop_name,
	ROUND(ST_Distance(stops.geog,parcels.geog)::numeric, 2) AS distance
FROM phl.pwd_parcels AS parcels
CROSS JOIN LATERAL (
  SELECT stops.stop_name,
		 stops.geog
  FROM septa.bus_stops AS stops
  ORDER BY parcels.geog <-> stops.geog
  LIMIT 1
) AS stops
ORDER BY distance DESC