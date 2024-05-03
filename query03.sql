/* Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).

Your query should run in under two minutes.
_HINT: This is a nearest neighbor problem.

(
    parcel_address text,  -- The address of the parcel
    stop_name text,  -- The name of the bus stop
    distance numeric  -- The distance apart in meters, rounded to two decimals
)
*/

SELECT * FROM septa.bus_stops;

SELECT * FROM phl.pwd_parcels;

SELECT bus_stops.stop_name,
       parcels.address AS parcel_address,
       nearest_parcel.dist
FROM septa.bus_stops AS bus_stops
CROSS JOIN LATERAL (
  SELECT ST_Distance(bus_stops.geog::geography, parcels.geog::geography) AS distance
  FROM phl.pwd_parcels AS parcels
  ORDER BY dist
  LIMIT 1
) nearest_parcel;

CREATE INDEX pwd_parcels_geog_idx ON phl.pwd_parcels USING GIST (geog);
CREATE INDEX bus_stops_geog_idx ON septa.bus_stops USING GIST (geog);