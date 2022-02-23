import select
import psycopg2
import psycopg2.extensions
import os


geom_set=set()

geom_set.add('lod0')
geom_set.add('lod1')
geom_set.add('lod2')
geom_set.add('lod3')

geom_set = sorted(list(geom_set))
print(type(geom_set))
print(geom_set)

for s in geom_set:
    print(s)
