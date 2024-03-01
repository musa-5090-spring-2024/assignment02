COPY septa.bus_routes
FROM 'C:\Users\richa\GitHub\musa_5090_assignment02\data\bus\routes.txt'
WITH (FORMAT csv, HEADER true);

COPY septa.bus_shapes
FROM 'C:\Users\richa\GitHub\musa_5090_assignment02\data\bus\shapes.txt'
WITH (FORMAT csv, HEADER true);

COPY septa.bus_stops
FROM 'C:\Users\richa\GitHub\musa_5090_assignment02\data\bus\stops.txt'
WITH (FORMAT csv, HEADER true);

COPY septa.bus_trips
FROM 'C:\Users\richa\GitHub\musa_5090_assignment02\data\bus\trips.txt'
WITH (FORMAT csv, HEADER true);

COPY septa.rail_stops
FROM 'C:\Users\richa\GitHub\musa_5090_assignment02\data\rail\stops.txt'
WITH (FORMAT csv, HEADER true)
