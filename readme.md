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
run `bundle exec falcon serve --bind http://localhost:9292` to start the server OR
run `RACK_ENV=development bundle exec falcon serve --bind http://localhost:9292` to start the server with hot reload

### Production:
Anonymoose runs in a microk8s kubernetes cluster
Useful commands
`microk8s kubectl apply -f example.yml -n your_namespace`
`microk8s kubectl get deployments -n your_namespace`
Essentially, throw `microk8s` in front of your normal `kubectl` commands.