
CREATE TABLE phl_water_dpt (
    parcel_address TEXT,
    geom GEOMETRY(Point, 4326) 
);

COPY phl_water_dpt (parcel_address, geom)
FROM '/Users/alyssafelix/Desktop/assignment0222/PWD_PARCELS.csv'
DELIMITER ',' CSV HEADER;


SELECT
    parcel.parcel_address AS parcel_address,
    stops.stop_name AS stop_name,
    ROUND(ST_Distance(parcel.geom::geography, stops.geog::geography)::numeric, 2) AS distance
FROM
    phl_water_dpt AS parcel
CROSS JOIN LATERAL (
    SELECT
        bus_stops.stop_name,
        bus_stops.geog
    FROM
        septa.bus_stops AS bus_stops
    ORDER BY
        parcel.geom <-> bus_stops.geog -- KNN operator: find the nearest bus stop to each parcel
    LIMIT 1
) AS stops
ORDER BY
    distance DESC; -- Order by distance, largest on top