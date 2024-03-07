WITH parcel_36th AS (
  SELECT ST_Centroid(geog)::geometry AS centroid
  FROM phl.pwd_parcels
  WHERE address ILIKE '%36th%'
  LIMIT 1
), parcel_walnut AS (
  SELECT ST_Centroid(geog)::geometry AS centroid
  FROM phl.pwd_parcels
  WHERE address ILIKE '%Locust%'
  LIMIT 1
), vertical_line AS (
  SELECT ST_MakeLine(ST_SetSRID(ST_Point(ST_X(parcel_36th.centroid), -90.0), 4326), ST_SetSRID(ST_Point(ST_X(parcel_36th.centroid), 90.0), 4326)) AS line
  FROM parcel_36th
), horizontal_line AS (
  SELECT ST_MakeLine(ST_SetSRID(ST_Point(-180.0, ST_Y(parcel_walnut.centroid)), 4326), ST_SetSRID(ST_Point(180.0, ST_Y(parcel_walnut.centroid)), 4326)) AS line
  FROM parcel_walnut
), intersection_point AS (
  SELECT ST_Intersection(vertical_line.line, horizontal_line.line)::geometry AS point
  FROM vertical_line, horizontal_line
)
SELECT cbg.geoid
FROM census.blockgroups_2020 AS cbg, intersection_point
WHERE ST_Intersects(cbg.geog::geometry, intersection_point.point);
