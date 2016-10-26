Elastic search sample app
===========

In this repository, I will study Elastic Search with Ruby on Rails.


## Environment

```
ruby 2.3.0
rail 5.0.0
postgresql
```


---


## Elasticsearch
- A powerful Full Text Search Engine based on Apache Lucene
- [Elasticsearch Scale Horizontally](https://www.elastic.co/guide/en/elasticsearch/guide/current/_scale_horizontally.html)
- Communicates with JSON
- Document-oriented
- [term suggester](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesters-term.html)

#### Install with Homebrew

```
brew install elasticsearch
```

#### Start Elasticsearch server

```
elasticsearch
```

#### Ruby gems

Low-level

- [The official elasticsearch  gem](https://github.com/elastic/elasticsearch-ruby)
- [The elasticsearch-model  gem](https://github.com/elastic/elasticsearch-rails/tree/master/elasticsearch-model)

High-level

- [ankane/searchkick](https://github.com/ankane/searchkick)

#### Structure

| RDB      | ES      ||
|---|---|---|
| database |  index  | each index can be split into multiple shards. |
| table    |  type   ||
| row      | document||
| column   |  field  ||


#### Monitoring tool
- [ElasticHQ](http://www.elastichq.org/index.html)


---


## Searchkick
- Supports the complete Elasticsearch Search API.

#### Gotchas
- When we use ElasticSearch, we cannot user ActiveRecord scoping.
- Everything needs to be specified to Searchkick through the `search` method's options.
- Call `rake searchkick:reindex:all` on the model every time we add/update data.
- By default, space between words means AND.
- By default, results must match the entire word.

#### Deployment

- Choose an add-on: SearchBox, Bonsai, or Elastic Cloud.
- [https://github.com/ankane/searchkick#deployment](https://github.com/ankane/searchkick#deployment)

```
git push heroku master     # Push up to Heroku repo
heroku pg:reset DATABASE   # reset the production database
heroku run rake db:migrate
heroku run rake db:seed
heroku run rake searchkick:reindex:all
```

---


## Autosuggest using typeahead.js
- [https://github.com/twitter/typeahead.js](https://github.com/twitter/typeahead.js)
- a fast and fully-featured autocomplete library
- predicts what a user will type


---


## Get started

```bash
bundle install
bundle exec rake db:migrate
bundle exec rake db:seed
```

---


## Models in this app

![](erd/erd.jpg)


---



## Resources

#### Elasticsearch
- [search-suggesters-term](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesters-term.html)
- [Full-Text Search in Rails Using Elasticsearch](https://code.tutsplus.com/articles/full-text-search-in-rails-using-elasticsearch--cms-22920) by Pedro Alonso
- [How to Use Searchkick and ElasticSearch in Your Rails App For Complex Search Indexing](http://aimeeault.com/2016/02/05/how-to-use-searchkick-and-elasticsearch-in-your-rails-app-for-complex-search-indexing/) by Aimee Ault
  + [https://github.com/aimee-ault/SearchkickSearch](https://github.com/aimee-ault/SearchkickSearch)
- [Elasticsearch with Ruby on Rails](http://tutorials.pluralsight.com/ruby-ruby-on-rails/elasticsearch-with-ruby-on-rails)
 by Itay Grudev
  + [https://github.com/itay-grudev/es-tutorial](https://github.com/itay-grudev/es-tutorial)
- [Full-Text Search in Rails Using Elasticsearch](https://code.tutsplus.com/articles/full-text-search-in-rails-using-elasticsearch--cms-22920)
- [Rails Search Gems: Searchkick vs Pg_Search](http://www.webascender.com/Blog/ID/713/Rails-Search-Gems-Searchkick-vs-Pg_Search#.WAuIc5MrLdR) BY MATT HALL
- [Rails, ElasticSearch & SearchKick in Depth](http://www.webascender.com/Blog/ID/752/Rails-ElasticSearch-SearchKick-in-Depth#.WAuIW5MrLdR) BY JOHN STEMLER


#### Deployment
- [How to setup elasticsearch on Heroku?](http://stackoverflow.com/a/38657992/3837223)


---


## TODO

#### Add markers for search results on the map
- get a list of lnglats for search result.
- pass the lnglat list to mapbox.
- add search result markers to map.

#### update markers when map has been moved.
- get the center lnglat when user stop moving the map.
- geo-search with that lnglat.

#### get user's current location
- get address from ip.


#### Some resources
- [#Map.event:moveend](https://www.mapbox.com/mapbox-gl-js/api/#Map.event:moveend)
- [#Map#getCenter](https://www.mapbox.com/mapbox-gl-js/api/#Map#getCenter)
- [Set a point after Geocoder result](https://www.mapbox.com/mapbox-gl-js/example/point-from-geocoder-result/)
- [The Ruby Toolbox - Geocoding & Maps](https://www.ruby-toolbox.com/categories/geocoding___maps)
- [alexreisner/geocoder: Complete Ruby geocoding solution.](https://github.com/alexreisner/geocoder)
- [searchkick#geospatial-searches](https://github.com/ankane/searchkick#geospatial-searches)
- [Geospatial Searches with Searchkick to find users](http://stackoverflow.com/a/22331111/3837223)
- [Rails - how to obtain visitors' IP address?](http://stackoverflow.com/questions/19317255/rails-how-to-obtain-visitors-ip-address)
- [ankane/searchkick: personalized-results](https://github.com/ankane/searchkick#personalized-results)


---


## License

This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
