# Anonymoose
A quick file sharing service. Upload a file and get a link to share with others. The file will be deleted after a certain amount of time or after a certain number of downloads.

## Roadmap:
- Frontend:
  - New options for max downloads and create option menu for it
  - Nice link generation when creating upload
- Backend:
  - Add logging middleware
  - Add error handling middleware
  - Add request id middleware
  - Add security headers
  - Add pricing
  - Add memberships
  - Add upload max downloads
  - CI/CD:
  - Kubernetes deployment through buildkite
  - Generate new valid cert for remote api access (TLS)

BUGS:
- need to add delete file if error on upload caching

TODO:
need to mask ttl time out of the form and into it's own enum / method
should probably edit the dockerfile to only use essential files, dump the test files and build a second Gemfile for prod

### Testing:
run `RACK_ENV=test rake test`

### Running locally:
run `bundle exec falcon serve --bind http://localhost:9292` to start the server OR
run `RACK_ENV=development bundle exec falcon serve --bind http://localhost:9292` to start the server with hot reload

### Production:
Anonymoose runs in a microk8s kubernetes cluster
Useful commands
`microk8s kubectl apply -f example.yml -n your_namespace`
`microk8s kubectl get deployments -n your_namespace`
Essentially, throw `microk8s` in front of your normal `kubectl` commands.