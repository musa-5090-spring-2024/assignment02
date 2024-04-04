WITH philly_blockgroups AS (
    SELECT
        bg.geoid,
        p.total,
        bg.geog
    FROM census.blockgroups_2020 AS bg
    INNER JOIN census.population_2020 AS p ON '1500000US' || bg.geoid = p.geoid
    WHERE bg.geoid LIKE '42101%'
),

bus_stop_populations AS (
    SELECT
        bs.stop_name,
        bs.geog,
        SUM(p.total) AS estimated_pop_800m
    FROM
        septa.bus_stops AS bs
    INNER JOIN philly_blockgroups AS p ON ST_DWITHIN(bs.geog, p.geog, 800)
    GROUP BY bs.stop_name, bs.geog
    HAVING SUM(p.total) > 500
)

SELECT
    stop_name,
    estimated_pop_800m,
    geog
FROM
    bus_stop_populations
ORDER BY estimated_pop_800m ASC
LIMIT 8;
