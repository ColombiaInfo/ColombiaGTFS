This file is based on the data that is located over here:
https://www.datos.gov.co/browse?q=gtfs&sortBy=relevance

There is new data thats need work:

http://datosabiertos.bogota.gov.co/dataset?_organization_limit=0&organization=sdm

The data downloaded from this location is not a valid gtfs file. There is some need of processing the .csv downloads. 

Problems:

* Double quoting
* Wrong geolocation is saved as a number
* a invalid column header
* route numbers containing dots (.)