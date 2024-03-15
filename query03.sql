SELECT
    pwd.address AS parcel_address,
    bs.stop_name AS stop_name,
    ROUND(ST_Distance(pwd.geog::geography, bs.geog::geography)::numeric, 2) AS distance
FROM
    phl.pwd_parcels AS pwd
CROSS JOIN LATERAL (
    SELECT
        bs.stop_name,
        bs.geog
    FROM
        septa.bus_stops AS bs
    ORDER BY
        pwd.geog <-> bs.geog -- noqa: LT02
    LIMIT
        1
) AS bs
ORDER BY
    distance DESC;
