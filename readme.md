# Anonymoose

![Docker Image Size (tag)](https://img.shields.io/docker/image-size/evilgenius13/anonymoose/prod?logo=docker)
![Dev Build](https://github.com/EvilGenius13/anonymoose/actions/workflows/ci.yml/badge.svg)
![Release Build](https://github.com/EvilGenius13/anonymoose/actions/workflows/prod-ci.yml/badge.svg)
[![Build status](https://badge.buildkite.com/0f5451722a0c03c7348769233f1f2c23df60736e67222a6ea5.svg)](https://buildkite.com/timewellspent/deployment)

### Description:
A quick file sharing service. Upload a file and get a link to share with others. The file will be deleted after a certain amount of time or after a certain number of downloads.

### Testing:
run `RACK_ENV=test rake test`

### Running locally:
run `rake dev` to start the server with hot reload

### Production:
Anonymoose runs in a microk8s kubernetes cluster
Useful commands
`microk8s kubectl apply -f example.yml -n your_namespace`
`microk8s kubectl get deployments -n your_namespace`
Essentially, throw `microk8s` in front of your normal `kubectl` commands.

### The Stack:
- [Server](https://i.dell.com/sites/csdocuments/Shared-Content_data-Sheets_Documents/en/R710-SpecSheet.pdf) Dell R710 running Ubuntu 24.04
- [Microk8's](https://microk8s.io/) to deploy a kubernetes cluster
- [Github Actions](https://github.com/features/actions) for CI testing. The app is booted in a docker container and tests run from there
- [Buildkite] for kubernetes deployments. It holds the scripts that take care of applying the kubernetes configurations
- [Puma](https://github.com/puma/puma) as the rack app and [Sinatra](https://github.com/sinatra/sinatra) for routes
- [Memcached](https://github.com/memcached/memcached) for link caching and file metadata
- [Minio](https://github.com/minio/minio) S3 storage for files
- [Sidekiq](https://github.com/sidekiq/sidekiq) for background jobs such as deleting files after TTL expiration **Coming Soon**
- [Redis](https://github.com/redis/redis) Used for Sidekiq **Coming Soon**
- [BeerCSS](https://github.com/beercss/beercss) Material Design
- [Axiom](https://axiom.co/) Logging and monitoring
- [OpenTelemetry](https://opentelemetry.io/) for tracing
- [K6](https://k6.io/) for load testing