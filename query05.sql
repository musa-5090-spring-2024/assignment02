WITH wheelchair_accessible_stops AS (
    SELECT
        n.name AS neighborhood_name,
        COUNT(bs.stop_id) AS wheelchair_accessible_bus_stops
    FROM
        azavea.neighborhoods n
    LEFT JOIN
        septa.bus_stops bs
    ON
        ST_Within(ST_SetSRID(bs.geog::geometry, 4326), ST_SetSRID(n.geog::geometry, 4326))
    WHERE
        bs.wheelchair_boarding IN (1, 2)
    GROUP BY
        n.name
)

SELECT
    neighborhood_name,
    wheelchair_accessible_bus_stops,
    CASE
        WHEN wheelchair_accessible_bus_stops >= 100 THEN 'High'
        WHEN wheelchair_accessible_bus_stops >= 50 THEN 'Medium'
        ELSE 'Low'
    END AS accessibility_rating
FROM
    wheelchair_accessible_stops
ORDER BY
    wheelchair_accessible_bus_stops DESC;

-- By using wheelchair_boarding column in bus_stops table, I counted the number of wheelchair boardings within the neighborhood. I think it is more important to have more accessible bus stops then considering inaccessible bus stops, because for people in wheelchiar, I think they are more comfortable with the neighborhood if it has many accessible stops. Then, I categorized them by high, medium, low for accessibility.
