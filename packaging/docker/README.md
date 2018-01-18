This builds [OpenInfoMan](https://github.com/openhie/openinfoman) and additional libraries for:
+ [Configurable Export to CSV](https://github.com/openhie/openinfoman-csv)
+ [RapidPro](https://github.com/openhie/openinfoman-rapidpro)
+ [Health Worker Registry](https://github.com/openhie/openinfoman-hwr)
+ [Inter-Linked Health Worker Registry Validation](https://github.com/openhie/openinfoman-ilr)
+ [DHIS2](https://github.com/openhie/openinfoman-dhis)

To use, just pull the image from Docker Hub and run it.
```
docker run -d -p 8984:8984 openhie/openinfoman
```

Or, clone the repo and build the file.
```
git clone https://github.com/openhie/openinfoman
cd openinfoman/packaging/docker
docker build .
docker run -d -p 8984:8984 <image hash>
```
