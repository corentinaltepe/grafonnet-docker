# grafonnet-docker
Unofficial [Grafonnet](https://github.com/grafana/grafonnet-lib) dockerfile and image for local and CI pipeline builds.
Inspired by [AndrewFarley/grafonnet-lib-dockerhub](https://github.com/AndrewFarley/grafonnet-lib-dockerhub).

This image is fit for local builds, Gitlab CI, Azure DevOps CI and probably more.

## Registries and Tags

Docker images are published to DockerHub and GitHub registries.
- [corentinaltepe/grafonnet](https://hub.docker.com/r/corentinaltepe/grafonnet)
- ghcr.io/corentinaltepe/grafonnet

Tags follow [Grafonnet releases](https://github.com/grafana/grafonnet-lib/releases). Find available tags
[here](https://github.com/users/corentinaltepe/packages/container/grafonnet/versions)
and [here](https://hub.docker.com/r/corentinaltepe/grafonnet/tags).

## How To

### Local Builds
To build a `mysourcefile.jsonnet` file into a `mysourcefile.json` dasbhoard for Grafana.

On Windows, do a `cd` to your source file:
```batch
docker run --rm -v %~dp0:/here corentinaltepe/grafonnet:latest jsonnet /here/mysourcefile.jsonnet >> %~dp0mysourcefile.json
```

On Linux, do a `cd` to your source file:
```bash
docker run --rm -v $(pwd):/here corentinaltepe/grafonnet:latest jsonnet /here/mysourcefile.jsonnet >> $(pwd)/mysourcefile.json
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

### CI Jobs
#### Azure DevOps
```yaml
- job: Build_Grafana_Dashboards
  container:
    image: corentinaltepe/grafonnet:0.1.0
  pool:
    vmImage: "ubuntu-latest"
  steps:
    # Build every .jsonnet file into a .json dashboard 
    # and place them in grafonnet-out/ directory
    - script: >
        mkdir grafonnet-out

        for file in Scripts/Metrics/grafonnet/*.jsonnet ; do 
          name=$(basename $file)
          jsonnet $file > grafonnet-out/grafana.${name%.jsonnet}.json
        done
```