![GitHub Release](https://img.shields.io/github/v/release/quodatum/basex-docker)
![GitHub Repo stars](https://img.shields.io/github/stars/quodatum/basex-docker)
![GitHub License](https://img.shields.io/github/license/quodatum/basex-docker)
![Docker Pulls](https://img.shields.io/docker/pulls/quodatum/basexhttp)
[![multi-arch docker buildx](https://github.com/Quodatum/basex-docker/actions/workflows/buildx.yml/badge.svg)](https://github.com/Quodatum/basex-docker/actions/workflows/buildx.yml)
# BaseX Dockerfile

Experiments with an alternative [BaseX](https://basex.org)  multi-architecture docker image. 

[Changelog](changelog.md)

## Features

- Supported platforms `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- Images are published to docker hub and github container repositories for each release. See github action script `buildx.yml`.

- Runs as user 1000 rather than 1984 (see https://docs.basex.org/wiki/Docker#Non-privileged_User)
- $BASEX_JVM environment support
- $SERVER_OPTS environment variable can set `basexhttp` server options.

## Additional libraries supplied in image
The image includes the jars below in `/lib/custom`
-  `saxon-HE-x.y.jar` from [Saxonica](https://www.saxonica.com/products/products.xml) to `lib/custom` for XSLT 3.0 support
- `xmlresolver-x.y.jar` [xmlresolver](https://github.com/xmlresolver/xmlresolver/releases)

## Pull
This image from [docker hub](https://hub.docker.com/r/quodatum/basexhttp)
```
docker pull quodatum/basexhttp:latest
```

This image from [github ghcr.io](https://github.com/Quodatum/basex-docker/pkgs/container/basexhttp)
```
docker pull ghcr.io/quodatum/basexhttp:latest
```


## Usage examples

### Simple test 
Create and start a container named `basex10` running the BaseX 10.3 http server on port 8080

```bash
docker run --name basex10 -p 8080:8080 -d quodatum/basexhttp:basex-10.3 
```
Confirm working by browsing to site root page i.e. http://your-host:8080/.
The DBA and Chat apps can not be used because no users are defined.

To create the admin user. Shell into the container...
```
 docker exec -it basex10 /bin/sh
```
and run
```
echo "your password" | basex -cPASSWORD
exit
```
Restart the container to pick up the change.

```
docker container restart basex10
```
Alternatively, you can supply a volume mapping that includes a prebuilt `users.xml` for `/srv/basex/data`


### Persist data and settings to a volume
```
docker volume create or use my-basex-data 

docker run  -p 8080:8080 \
            -v my-basex-data:/srv/basex/data \
            -d quodatum/basexhttp:latest 
```
### Persist data and settings to a local folder
```
mkdir data 
chown -R 1000:1000 data

docker run  -p 8080:8080 \
            -v ./data:/srv/basex/data \
            -d quodatum/basexhttp:latest 
```
### Shadow web server root page
```
cat root.xqm
module namespace _ = 'urn:quodatum:test';
declare %rest:GET %rest:path('') %output:method('text')
function _:root(){
"Hello, I'm a new text only front page"
};

docker run  -p 8080:8080 \
            -v ./data:/srv/basex/data \
            -v ./root.xqm:/srv/basex/webapp/restxq.xqm \
            -d quodatum/basexhttp:latest
```
### Webapp
Install a local web app with custom repository entries
```
docker run  -p 28080:8080 \
            -v ./webapp:/srv/basex/webapp \
            -v ./repo:/srv/basex/repo \
            quodatum/basexhttp:latest
```
## Docker-compose
A simple case is provided in `samples` folder.

The compose file below shows the use of setting the `SERVER_OPTS` variable to run  a custom script (here `basex/setup.bxs`) before starting the httpserver.
```yaml
services:
  basex:
    image: localhost/fred2
    container_name: mdui
    restart: unless-stopped
    ports:
      - "9093:8080"
      - "9094:1984"
    volumes:
      - basex-data:/srv/basex/data 
      - ./webapp/app:/srv/basex/webapp/app
      - ./setup.bxs:/srv/basex/setup.bxs

    environment:
      - "SERVER_OPTS= -c basex/setup.bxs"
    volumes_from:
      - pdfdata
     
  pdfdata:
    image: abc/data:latest

volumes:
  basex-data: # basex state users and databases
    name: basex-data
    external: true
```
A more complex usage with a BaseX service running with other components is shown [here](https://github.com/willhoeft-it/basex-oauth2/blob/8b9a830a6864dbfdb26abdcc9f34f6480c81f786/docker-compose.yml#L82)
## Supported JVM versions
Tested largely with `eclipse-temurin:17-jre`. This is based on ubuntu latest. It is used because it is available for all the supported platforms.

Java15+ is required to avoid possiblity of container termination due to resource limit policies.
See [OpenJDK's container awareness code](https://developers.redhat.com/articles/2022/04/19/java-17-whats-new-openjdks-container-awareness#recent_changes_in_openjdk_s_container_awareness_code)


## Dockerfile notes

### JVM options
#### inaccessibleobjectexception
This is only relevant when running BaseX versions compiled for `Java8` on JVMs `Java9+`
* --add-opens java.base/java.net=ALL-UNNAMED 
* --add-opens java.base/jdk.internal.loader=ALL-UNNAMED
 
See [How to solve InaccessibleObjectException ("Unable to make {member} accessible: module {A} does not 'opens {package}' to {B}") on Java 9?](https://stackoverflow.com/questions/41265266/how-to-solve-inaccessibleobjectexception-unable-to-make-member-accessible-m)




## See also
The official BaseX image on docker hub. Currently unmaintained. More information at
 [basex#2051](https://github.com/BaseXdb/basex/issues/2051)
```
docker pull basex/basexhttp:latest
```

## Components
* [BaseX](https://basex.org/about/open-source/) 3-clause BSD License

* [Saxon-HE](https://sourceforge.net/projects/saxon/) Mozilla Public License 2.0 

* [XMLresolver](https://github.com/xmlresolver/xmlresolver) Apache License version 2.0
