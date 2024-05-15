SELECT
    p.address::text AS parcel_address,
    b.stop_name::text AS stop_name,
    ROUND(ST_Distance(parcel.geog::geometry, stop.geog::geometry)::numeric, 2) AS distance
FROM
    septa.bus_stops AS stop
CROSS JOIN LATERAL (
    SELECT
        parcel.address,
        parcel.geog
    FROM
        phl.pwd_parcels AS parcel
    ORDER BY
        parcel.geog <-> stop.geog
    LIMIT 1
) p;