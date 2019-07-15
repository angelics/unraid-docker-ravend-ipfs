## Usage

```
docker pull angelics/unraid-docker-ravencoin-p2p

```

```
docker run [-d] \
    --name=ravencoinp2p \
    -e TZ=Asia/Singapore \
    -e USER_ID=99 \
    -e GROUP_ID=100 \
    -e BOOTSTRAP=0 \
    -v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    -p 8767:8767/tcp \
    angelics/unraid-docker-ravencoin-p2p
```

```
docker exec ravencoinp2p tail -f /storage/.raven/debug.log
docker exec ravencoinp2p sh /check_status.sh

```

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`USER_ID`| ID of the user the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`GROUP_ID`| ID of the group the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`SUP_GROUP_IDS`| Comma-separated list of supplementary group IDs of the application. | (unset) |
|`UMASK`| Mask that controls how file permissions are set for newly created files. The value of the mask is in octal notation.  By default, this variable is not set and the default umask of `022` is used, meaning that newly created files are readable by everyone, but only writable by the owner. See the following online umask calculator: http://wintelguy.com/umask-calc.pl | (unset) |
|`TZ`| [TimeZone] of the container.  Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`KEEP_APP_RUNNING`| When set to `1`, the application will be automatically restarted if it crashes or if user quits it. | `0` |
|`APP_NICENESS`| Priority at which the application should run.  A niceness value of -20 is the highest priority and 19 is the lowest priority.  By default, niceness is not set, meaning that the default niceness of 0 is used.  **NOTE**: A negative niceness (priority increase) requires additional permissions.  In this case, the container should be run with the docker option `--cap-add=SYS_NICE`. | (unset) |
|`CLEAN_TMP_DIR`| When set to `1`, all files in the `/tmp` directory are delete during the container startup. | `1` |
|`BOOTSTRAP`| When set to `1`, application will download the latest bootsrap file provided by ravenland.org | `0` |
