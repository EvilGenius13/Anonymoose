Running app: bundle exec falcon serve --bind http://localhost:9292
Temp bound to http://localhost:9292 in order to mitigate the SSL error.

Dev hot reload: RACK_ENV=development bundle exec falcon serve --bind http://localhost:9292

how to set all env variables and load at app start
create caching middleware instead of calling in app.rb


Features:
Add caching middleware
Add logging middleware
Add error handling middleware
Add request id middleware
headers
security
pricing
memberships
upload TTL
upload max downloads


BUGS:
- need to add delete file if error on upload caching

TODO:
Probably need to create the uploads folder in the root directory on docker image build

### Testing:
run `RACK_ENV=test rake test`

