This file is based on the data that is located over here:
https://www.datos.gov.co/browse?q=gtfs&sortBy=relevance

https://datosabiertos-transmilenio.hub.arcgis.com/search?collection=Document&sort=-modified&tags=gtfs

Shapes:

https://datosabiertos-transmilenio.hub.arcgis.com/datasets/rutas-troncales-de-transmilenio

https://datosabiertos-transmilenio.hub.arcgis.com/datasets/rutas-zonales-provisionales-del-sitp


There is new data thats need work:

http://datosabiertos.bogota.gov.co/dataset?_organization_limit=0&organization=sdm

The data downloaded from this location is not a valid gtfs file. There is some need of processing the .csv downloads. 

Problems:

* Double quoting
* Wrong geolocation is saved as a number
* a invalid column header
* route numbers containing dots (.)
* stop_times file is not complete
