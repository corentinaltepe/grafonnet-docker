# grafonnet-docker
Unofficial [Grafonnet](https://github.com/grafana/grafonnet-lib) dockerfile and image for local and CI pipeline builds.
Inspired by [AndrewFarley/grafonnet-lib-dockerhub](https://github.com/AndrewFarley/grafonnet-lib-dockerhub).

This image is fit for local builds, Gitlab CI, Azure DevOps CI and probably more.

## Registries and Tags

Docker images are published to DockerHub and Github registries.
- corentinaltepe/grafonnet : DockerHub
- ghcr.io/corentinaltepe/grafonnet : Github

Tags follow [Grafonnet](https://github.com/grafana/grafonnet-lib) releases. Available tags:
- latest: Grafonnet's master head
- 0.1.0
- 0.0.1

## How To

### Local Builds
To build a `mysourcefile.jsonnet` file into a `mysourcefile.json` dasbhoard for Grafana.

On Windows, do a `cd` to your source file:
```batch
docker run --rm -v %~dp0:/here corentinaltepe/grafonnet:latest jsonnet /here/mysourcefile.jsonnet >> %~dp0%1.json
```

On Linux, do a `cd` to your source file:
```bash
docker run --rm -v $(pwd):/here corentinaltepe/grafonnet:latest jsonnet /here/mysourcefile.jsonnet >> %~dp0%1.json
```

### Automatically Build and Load to Grafana
The following script builds a file for Grafana's API and then pushes it to Grafana. It is written for Windows.
Replace `%~dp0` with `$(pwd)` for Linux.
```batch
::: Build the dashboard *.jsonnet to *.json
echo { "dashboard": > %~dp0myfile.json
docker run --rm -v %~dp0:/here corentinaltepe/grafonnet:latest jsonnet /here/myfile.jsonnet >> %~dp0myfile.json
echo , "overwrite": true} >> %~dp0myfile.json

::: Load to Grafana
::: Replace admin:admin with your credentials or add authentication bearer in HTTP headers
curl -X POST -H "Content-Type: application/json" -d @%~dp0myfile.json "http://admin:admin@localhost:3000/api/dashboards/db"
```