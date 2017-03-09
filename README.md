# Eatout
 *"When in doubt, eat out!"*

This repo contains code for the web application created using the [**Yelp Fusion API**](https://www.yelp.com/developers), showing average ratings of each state, and allowing users to navigate through different locations to search for restaurants corresponding to that location.

### Choropleth Map
The choropleth map (or the heat map) is the first aspect seen on the website. The color of the region of each state corresponds to the average rating of all the restaurants from the state. (data from: [Evan Moran](http://cse.msu.edu/~moraneva/cse491Project/)). The darker the shade of the region, the higher its average rating. Hovering over each state in the map provides the state name and its average rating. It is also possible to click on a particular state to get a response of a few restaurants in that region.

### Search Panel
It is possible to get specific results from Yelp by **entering a location**(as a zipcode, address, city name, state name, or coordinates). Furthermore, it can be filtered by the restaurants that are currently open.

### Results for location
The resultant map from entering a particular location or clicking on a state on the choropleth map, zooms in to the region with popups. Each popup contains the restaurant's name (clicking on the name links to the corresponding Yelp website with more information), rating, address, phone number and a corresponding image provided by Yelp.

### Pie Chart
The search panel also provides a **pie chart** that shows the proportions of the most popular cuisines in the selected region, and colored distinctly to the type of cuisine.

### Data Tables
The web application also provides **data corresponding to the current visualization**. For the choropleth map, it shows the average ratings per state, whereas for specific regions it provides the name of the regions and their ratings.
