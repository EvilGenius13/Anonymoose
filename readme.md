# Anonymoose
A quick file sharing service. Upload a file and get a link to share with others. The file will be deleted after a certain amount of time or after a certain number of downloads.

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
need to mask ttl time out of the form and into it's own enum / method
should probably edit the dockerfile to only use essential files, dump the test files and build a second Gemfile for prod

### Testing:
run `RACK_ENV=test rake test`


### Production:
Anonymoose runs in a microk8s kubernetes cluster
Useful commands
`microk8s kubectl apply -f example.yml -n your_namespace`
`microk8s kubectl get deployments -n your_namespace`
Essentially, throw `microk8s` in front of your normal `kubectl` commands.