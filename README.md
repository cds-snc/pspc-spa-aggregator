# Aggregator

This repo contains the aggregator portion of the SPA. The aggregator provides
the tools to upload OCDS data into the database and to show/search for that data
which is then exported in OCDS format.

```
bundle install
rake db:create db:migrate
rails r ./bin/ocds_loader <ocds file with required fields>
rails s -p 3001
```
