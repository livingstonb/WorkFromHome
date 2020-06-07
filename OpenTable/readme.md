# OpenTable

## Required inputs

We use a dataset provided by OpenTable, downloaded from <https://www.opentable.com/state-of-industry>.

* *build/input/state_of_industry.csv*

To rank cities by population, we use 2018 estimates produced by the Census, downloaded from
<https://www.census.gov/data/tables/time-series/demo/popest/2010s-total-cities-and-towns.html>.
Population ranks were then coded into *city_data.csv*, along with the approximate dates at which city or state dine-in bans went into effect.

* *build/input/city_data.csv*