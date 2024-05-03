WITH dist AS (
    SELECT
        r.stop_id,
        ROUND(
            (ST_DISTANCE(
                r.geog::geography, ST_MAKEPOINT(-75.1636, 39.9526)::geography
            ) * 0.000621371)::numeric, 2
        ) AS dist2ch
    FROM septa.rail_stops AS r
    GROUP BY r.stop_id, r.geog
),

stop_desc_calculation AS (
    SELECT
        rail.stop_id,
        CONCAT(
            dist.dist2ch,
            ' mi to City Hall and ',
            COUNT(bus.*),
            ' bus stops within 1/4 mi'
        ) AS stop_desc
    FROM septa.rail_stops AS rail
    LEFT JOIN septa.bus_stops AS bus
        ON ST_DWITHIN(bus.geog, rail.geog, 402.336 * 3.28084)
    LEFT JOIN dist
        ON rail.stop_id = dist.stop_id
    GROUP BY
        rail.stop_id,
        dist.dist2ch
)

SELECT
    rail.stop_id,
    rail.stop_name,
    stop_desc_calculation.stop_desc,
    rail.stop_lon,
    rail.stop_lat
FROM septa.rail_stops AS rail
LEFT JOIN stop_desc_calculation
    ON rail.stop_id = stop_desc_calculation.stop_id
LEFT JOIN dist
    ON rail.stop_id = dist.stop_id
ORDER BY dist.dist2ch ASC;
