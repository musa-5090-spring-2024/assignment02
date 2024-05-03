import csv
import json
import pathlib

with open(
    'census_population_2020.json',
    'r', encoding='utf-8',
) as infile:
    data = json.load(infile)

with open(
    'census_population_2020.csv',
    'w', encoding='utf-8',
) as outfile:
    writer = csv.writer(outfile)
    writer.writerows([
        (row[1], row[0], row[2])
        for row in data
    ])