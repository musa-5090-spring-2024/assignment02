/* Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).

*/

SELECT parcels.address AS parcel_address,
       nearest_stop.stop_name AS stop_name,
       ROUND(ST_DISTANCE(nearest_stop.geog, parcels.geog)::numeric, 2) AS distance
FROM phl.pwd_parcels AS parcels
JOIN LATERAL (
  SELECT stop_name, geog
  FROM septa.bus_stops
  ORDER BY geog <-> parcels.geog
  LIMIT 1
) AS nearest_stop ON true
ORDER BY 
    distance DESC;
