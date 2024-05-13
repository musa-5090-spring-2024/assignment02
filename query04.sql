WITH CTE AS (
    SELECT
		septa.bus_trips.route_id AS route_short_name,
		septa.bus_trips.shape_id,
-- 		septa.bus_trips.trip_headsign,
-- 		shape_geoms.shape_geom,
-- 		shape_geoms.shape_id AS geom_shape_id,
        s.shape_id AS shapes_shape_id,
        s.shape_pt_lat,
        s.shape_pt_lon,
        s.shape_pt_sequence,
        LEAD(s.shape_pt_lat) OVER (PARTITION BY s.shape_id ORDER BY s.shape_pt_sequence) AS next_lat,
        LEAD(s.shape_pt_lon) OVER (PARTITION BY s.shape_id ORDER BY s.shape_pt_sequence) AS next_lon
    FROM
        shapes as s
	INNER JOIN
		septa.bus_trips ON septa.bus_trips.shape_id = CAST(s.shape_id AS NUMERIC)
-- 	INNER JOIN
-- 		shape_geoms ON shape_geoms.shape_id = s.shape_id
)
SELECT
	shapes_shape_id,
--  route_short_name,
-- 	septa.bus_trips.trip_headsign,
-- 	public.shape_geoms.shape_geom,
    SUM(
        ROUND(
            CAST(
                6371 * 2 * ASIN(
                    SQRT(
                        POWER(SIN((RADIANS(next_lat) - RADIANS(shape_pt_lat)) / 2), 2) +
                        COS(RADIANS(shape_pt_lat)) * COS(RADIANS(next_lat)) *
                        POWER(SIN((RADIANS(next_lon) - RADIANS(shape_pt_lon)) / 2), 2)
                    )
                ) AS NUMERIC
            ),
            4
        )
    ) AS shape_length
FROM
    CTE
GROUP BY
    CTE.shapes_shape_id
ORDER BY
    shape_length DESC
LIMIT 2;





WITH CTE AS (
    SELECT
        shape_id,
        shape_pt_lat,
        shape_pt_lon,
        shape_pt_sequence,
        LEAD(shape_pt_lat) OVER (PARTITION BY shape_id ORDER BY shape_pt_sequence) AS next_lat,
        LEAD(shape_pt_lon) OVER (PARTITION BY shape_id ORDER BY shape_pt_sequence) AS next_lon
    FROM
        shapes
)
SELECT
    shape_id,
    SUM(
        ROUND(
			CAST (
				6371 * 2 * ASIN(
					SQRT(
						POWER(SIN((RADIANS(next_lat) - RADIANS(shape_pt_lat)) / 2), 2) +
						COS(RADIANS(shape_pt_lat)) * COS(RADIANS(next_lat)) *
						POWER(SIN((RADIANS(next_lon) - RADIANS(shape_pt_lon)) / 2), 2)
					)
				) 
			AS NUMERIC),
            4
        )
    ) AS total_distance_km
FROM
    CTE
GROUP BY
    shape_id
ORDER BY
    total_distance_km DESC
LIMIT 2;

)
SELECT
    br.route_short_name,
    bt.trip_headsign,
    bs.shape_geog,
    ROUND(td.total_distance_km * 1000) AS shape_length
FROM
    bus_routes br
JOIN
    bus_trips bt ON br.route_id = bt.route_id
JOIN
    bus_shapes bs ON bt.shape_id = bs.shape_id
JOIN
    TotalDistance td ON bt.shape_id = td.shape_id
ORDER BY
    shape_length DESC
LIMIT 2;


WITH CTE AS (
    SELECT
        shape_id,
        shape_pt_lat,
        shape_pt_lon,
        shape_pt_sequence,
        LEAD(shape_pt_lat) OVER (PARTITION BY shape_id ORDER BY shape_pt_sequence) AS next_lat,
        LEAD(shape_pt_lon) OVER (PARTITION BY shape_id ORDER BY shape_pt_sequence) AS next_lon
    FROM
        shapes
),
TotalDistance AS (
    SELECT
        shape_id,
        SUM(
            ROUND(
                CAST(
                    6371 * 2 * ASIN(
                        SQRT(
                            POWER(SIN((RADIANS(next_lat) - RADIANS(shape_pt_lat)) / 2), 2) +
                            COS(RADIANS(shape_pt_lat)) * COS(RADIANS(next_lat)) *
                            POWER(SIN((RADIANS(next_lon) - RADIANS(shape_pt_lon)) / 2), 2)
                        )
                    ) AS NUMERIC
                ),
                4
            )
        ) AS total_distance_km
    FROM
        CTE
    GROUP BY
        shape_id
)
SELECT
    trip.route_short_name,
    trip.trip_headsign,
    s.shape_geog,
    ROUND(td.total_distance_km * 1000) AS shape_length
FROM
    trips t
JOIN
    shape_geoms s ON t.shape_id = s.shape_id
JOIN
    TotalDistance td ON t.shape_id = td.shape_id;