/*Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips.
structure
(
    route_short_name text,  -- The short name of the route
    trip_headsign text,  -- Headsign of the trip
    shape_geog geography,  -- The shape of the trip
    shape_length numeric  -- Length of the trip in meters, rounded to the nearest whole number
)*/

WITH shape_lines AS (
  SELECT
    shape_id,
    ST_SetSRID(ST_MakeLine(ST_MakePoint(shape_pt_lon, shape_pt_lat) ORDER BY shape_pt_sequence), 4326) AS shape_geog
  FROM
    septa.bus_shapes
  GROUP BY
    shape_id
),
trip_lengths AS (
  SELECT
    r.route_short_name,
    t.trip_headsign,
    s.shape_geog,
    ROUND(ST_Length(s.shape_geog::geography)) AS shape_length
  FROM
    septa.bus_routes AS r
  JOIN
    septa.bus_trips AS t ON r.route_id = t.route_id
  JOIN
    shape_lines AS s ON t.shape_id = s.shape_id
),
ranked_trips AS (
  SELECT
    route_short_name,
    trip_headsign,
    shape_geog,
    shape_length,
    ROW_NUMBER() OVER (ORDER BY shape_length DESC) AS rn
  FROM
    trip_lengths
)
SELECT
  route_short_name,
  trip_headsign,
  shape_geog,
  shape_length
FROM
  ranked_trips
WHERE
  rn <= 2

