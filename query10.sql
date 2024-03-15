WITH wheelchair_accessible_bus_stops AS (
    SELECT
        bs.stop_id AS stop_id,
        COUNT(*) AS num_accessible_stops
    FROM
        septa.bus_stops bs
    WHERE
        bs.wheelchair_boarding IN (1, 2)
    GROUP BY
        bs.stop_id
),

nearest_stops AS (
    SELECT
        rs.stop_id AS stop_id,
        COUNT(*) AS num_nearest_stops
    FROM
        septa.rail_stops rs
    LEFT JOIN
        septa.bus_stops bs
    ON
        ST_Distance(
            ST_Transform(ST_SetSRID(ST_MakePoint(rs.stop_lon, rs.stop_lat), 4326), 3857),
            ST_Transform(ST_SetSRID(ST_MakePoint(bs.stop_lon, bs.stop_lat), 4326), 3857)
        ) <= 100
    AND
        bs.wheelchair_boarding IN (1, 2)
    GROUP BY
        rs.stop_id
)

SELECT
    rs.stop_id,
    rs.stop_name,
    COALESCE(CONCAT(nearest_stops.num_nearest_stops, ' wheelchair accessible bus stops within 100 meters of the rail stop'), '0 wheelchair accessible bus stops within 100 meters of the rail stop') AS stop_desc,
    rs.stop_lon,
    rs.stop_lat
FROM
    septa.rail_stops rs
LEFT JOIN
    nearest_stops
ON
    rs.stop_id = nearest_stops.stop_id;
