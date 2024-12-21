# Factorio [![Docker Version](https://img.shields.io/docker/v/factoriotools/factorio?sort=semver)](https://hub.docker.com/r/factoriotools/factorio/) [![Docker Pulls](https://img.shields.io/docker/pulls/factoriotools/factorio.svg?maxAge=600)](https://hub.docker.com/r/factoriotools/factorio/) [![Docker Stars](https://img.shields.io/docker/stars/factoriotools/factorio.svg?maxAge=600)](https://hub.docker.com/r/factoriotools/factorio/)

Mark's Azure configuration.

> [!NOTE]
> Support for ARM is experimental. Expect crashes and lag if you try to run this on a raspberry pi.

[中文](./README_zh_CN.md)

<!-- start autogeneration tags -->
* `2.0.28`, `latest`
* `2.0.27`
* `2.0.26`
* `2.0.25`
* `2.0.24`
* `2`, `2.0`, `2.0.23`, `stable`, `stable-2.0.23`
* `2.0.22`
* `2.0`, `2.0.21`, `stable-2.0.21`
* `2.0`, `2.0.20`, `stable-2.0.20`
* `2.0.19`
* `2.0.18`
* `2.0.17`
* `2.0.16`
* `2.0`, `2.0.15`, `stable-2.0.15`
* `2.0`, `2.0.14`, `stable-2.0.14`
* `2.0`, `2.0.13`, `stable-2.0.13`
* `1`, `1.1`, `1.1.110`, `stable-1.1.110`
* `1.0`, `1.0.0`
* `0.17`, `0.17.79`
* `0.16`, `0.16.51`
* `0.15`, `0.15.40`
* `0.14`, `0.14.23`
* `0.13`, `0.13.20`
* `0.12`, `0.12.35`<!-- end autogeneration tags -->

## Tag descriptions

* `latest` - most up-to-date version (may be experimental).
* `stable` - version declared stable on [factorio.com](https://www.factorio.com) ([FFF-435 Since 2.0 versions gets released as experimental first, once stable it will be marked as stable](https://factorio.com/blog/post/fff-435)).
* `0.x`    - latest version in a branch.
* `0.x.y` - a specific version.
* `0.x-z` - incremental fix for that version.

## What is Factorio?

[Factorio](https://www.factorio.com) is a game in which you build and maintain factories.

You will be mining resources, researching technologies, building infrastructure, automating production and fighting enemies. Use your imagination to design your factory, combine simple elements into ingenious structures, apply management skills to keep it working and finally protect it from the creatures who don't really like you.

The game is very stable and optimized for building massive factories. You can create your own maps, write mods in Lua or play with friends via Multiplayer.

NOTE: This is only the server. The full game is available at [Factorio.com](https://www.factorio.com), [Steam](https://store.steampowered.com/app/427520/), [GOG.com](https://www.gog.com/game/factorio) and [Humble Bundle](https://www.humblebundle.com/store/factorio).

## Usage

### Quick Start

Run the server to create the necessary folder structure and configuration files. For this example data is stored in `/opt/factorio`.

```shell
sudo mkdir -p /opt/factorio
sudo chown 845:845 /opt/factorio
sudo docker run -d \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -v /opt/factorio:/factorio \
  --name factorio \
  --restart=unless-stopped \
  factoriotools/factorio
```

For those new to Docker, here is an explanation of the options:

* `-d` - Run as a daemon ("detached").
* `-p` - Expose ports.
* `-v` - Mount `/opt/factorio` on the local file system to `/factorio` in the container.
* `--restart` - Restart the server if it crashes and at system start
* `--name` - Name the container "factorio" (otherwise it has a funny random name).

The `chown` command is needed because in 0.16+, we no longer run the game server as root for security reasons, but rather as a 'factorio' user with user id 845. The host must therefore allow these files to be written by that user.

Check the logs to see what happened:

```shell
docker logs factorio
```

Stop the server:

```shell
docker stop factorio
```

Now there's a `server-settings.json` file in the folder `/opt/factorio/config`. Modify this to your liking and restart the server:

```shell
docker start factorio
```

Try to connect to the server. Check the logs if it isn't working.

### Console

To issue console commands to the server, start the server in interactive mode with `-it`. Open the console with `docker attach` and then type commands.

```shell
docker run -d -it  \
      --name factorio \
      factoriotools/factorio
docker attach factorio
```

### RCON (2.0.18+)

Alternativly (e.g. for scripting) the RCON connection can be used to send commands to the running factorio server.
This does not require the RCON connection to be exposed.

```shell
docker exec factorio rcon /h
```

### Upgrading

Before upgrading backup the save. It's easy to make a save in the client.

Ensure `-v` was used to run the server so the save is outside of the Docker container. The `docker rm` command completely destroys the container, which includes the save if it isn't stored in a data volume.

Delete the container and refresh the image:

```shell
docker stop factorio
docker rm factorio
docker pull factoriotools/factorio
```

Now run the server as before. In about a minute the new version of Factorio should be up and running, complete with saves and config!

### Saves

A new map named `_autosave1.zip` is generated the first time the server is started. The `map-gen-settings.json` and `map-settings.json` files in `/opt/factorio/config` are used for the map settings. On subsequent runs the newest save is used.

To load an old save stop the server and run the command `touch oldsave.zip`. This resets the date. Then restart the server. Another option is to delete all saves except one.

To generate a new map stop the server, delete all of the saves and restart the server.

#### Specify a save directly (0.17.79-2+)

You can specify a specific save to load by configuring the server through a set of environment variables:

To load an existing save set `SAVE_NAME` to the name of your existing save file located within the `saves` directory, without the `.zip` extension:

```shell
sudo docker run -d \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -v /opt/factorio:/factorio \
  -e LOAD_LATEST_SAVE=false \
  -e SAVE_NAME=replaceme \
  --name factorio \
  --restart=unless-stopped \
  factoriotools/factorio
```

To generate a new map set `GENERATE_NEW_SAVE=true` and specify `SAVE_NAME`:

```shell
sudo docker run -d \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -v /opt/factorio:/factorio \
  -e LOAD_LATEST_SAVE=false \
  -e GENERATE_NEW_SAVE=true \
  -e SAVE_NAME=replaceme \
  --name factorio \
  --restart=unless-stopped \
  factoriotools/factorio
```

### Mods

Copy mods into the mods folder and restart the server.

As of 0.17 a new environment variable was added ``UPDATE_MODS_ON_START`` which if set to ``true`` will cause the mods get to updated on server start. If set a valid [Factorio Username and Token](https://www.factorio.com/profile) must be supplied or else the server will not start. They can either be set as docker secrets, environment variables, or pulled from the server-settings.json file.

### Scenarios

If you want to launch a scenario from a clean start (not from a saved map) you'll need to start the docker image from an alternate entrypoint. To do this, use the example entrypoint file stored in the /factorio/entrypoints directory in the volume, and launch the image with the following syntax. Note that this is the normal syntax with the addition of the --entrypoint setting AND the additional argument at the end, which is the name of the Scenario in the Scenarios folder.

```shell
docker run -d \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -v /opt/factorio:/factorio \
  --name factorio \
  --restart=unless-stopped  \
  --entrypoint "/scenario.sh" \
  factoriotools/factorio \
  MyScenarioName
```

### Converting Scenarios to Regular Maps

If you would like to export your scenario to a saved map, you can use the example entrypoint similar to the Scenario usage above. Factorio will run once, converting the Scenario to a saved Map in your saves directory. A restart of the docker image using the standard options will then load that map, just as if the scenario were just started by the Scenarios example noted above.

```shell
docker run -d \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -v /opt/factorio:/factorio \
  --name factorio \
  --restart=unless-stopped  \
  --entrypoint "/scenario2map.sh" \
  factoriotools/factorio
  MyScenarioName
```

### RCON

Set the RCON password in the `rconpw` file. A random password is generated if `rconpw` doesn't exist.

To change the password, stop the server, modify `rconpw`, and restart the server.

To "disable" RCON don't expose port 27015, i.e. start the server without `-p 27015:27015/tcp`. RCON is still running, but nobody can to connect to it.

### Whitelisting (0.15.3+)

Create file `config/server-whitelist.json` and add the whitelisted users.

```json
[
"you",
"friend"
]
```

### Banlisting (0.17.1+)

Create file `config/server-banlist.json` and add the banlisted users.

```json
[
"bad_person",
"other_bad_person"
]
```

### Adminlisting (0.17.1+)

Create file `config/server-adminlist.json` and add the adminlisted users.

```json
[
"you",
"friend"
]
```

### Customize configuration files (0.17.x+)

Out-of-the box, factorio does not support environment variables inside the configuration files. A workaround is the usage of `envsubst` which generates the configuration files dynamically during startup from environment variables set in docker-compose:

Example which replaces the server-settings.json:

```yaml
factorio_1:
  image: factoriotools/factorio
  ports:
    - "34197:34197/udp"
  volumes:
   - /opt/factorio:/factorio
   - ./server-settings.json:/server-settings.json
  environment:
    - INSTANCE_NAME=Your Instance's Name
    - INSTANCE_DESC=Your Instance's Description
  entrypoint: /bin/sh -c "mkdir -p /factorio/config && envsubst < /server-settings.json > /factorio/config/server-settings.json && exec /docker-entrypoint.sh"
```

The `server-settings.json` file may then contain the variable references like this:

```json
"name": "${INSTANCE_NAME}",
"description": "${INSTANCE_DESC}",
```

### Environment Variables

These are the environment variables which can be specified at container run time.

| Variable Name        | Description                                                          | Default        | Available in |
|----------------------|----------------------------------------------------------------------|----------------|--------------|
| GENERATE_NEW_SAVE    | Generate a new save if one does not exist before starting the server | false          | 0.17+        |
| LOAD_LATEST_SAVE     | Load latest when true. Otherwise load SAVE_NAME                      | true           | 0.17+        |
| PORT                 | UDP port the server listens on                                       | 34197          | 0.15+        |
| BIND                 | IP address (v4 or v6) the server listens on (IP\[:PORT])             |                | 0.15+        |
| RCON_PORT            | TCP port the rcon server listens on                                  | 27015          | 0.15+        |
| SAVE_NAME            | Name to use for the save file                                        | _autosave1     | 0.17+        |
| TOKEN                | factorio.com token                                                   |                | 0.17+        |
| UPDATE_MODS_ON_START | If mods should be updated before starting the server                 |                | 0.17+        |
| USERNAME             | factorio.com username                                                |                | 0.17+        |
| CONSOLE_LOG_LOCATION | Saves the console log to the specifies location                      |                |              |
| DLC_SPACE_AGE        | Enables or disables the mods for DLC Space Age in mod-list.json[^1]  | true           | 2.0.8+       |
| MODS                 | Mod directory to use                                                 | /factorio/mods | 2.0.8+       |

**Note:** All environment variables are compared as strings

## Container Details

The philosophy is to [keep it simple](http://wiki.c2.com/?KeepItSimple).

* The server should bootstrap itself.
* Prefer configuration files over environment variables.
* Use one volume for data.

### Volumes

To keep things simple, the container uses a single volume mounted at `/factorio`. This volume stores configuration, mods, and saves.

The files in this volume should be owned by the factorio user, uid 845.

```text
  factorio
  |-- config
  |   |-- map-gen-settings.json
  |   |-- map-settings.json
  |   |-- rconpw
  |   |-- server-adminlist.json
  |   |-- server-banlist.json
  |   |-- server-settings.json
  |   `-- server-whitelist.json
  |-- mods
  |   `-- fancymod.zip
  `-- saves
      `-- _autosave1.zip
```

## Docker Compose

[Docker Compose](https://docs.docker.com/compose/install/) is an easy way to run Docker containers.

* docker-engine >= 1.10.0 is required
* docker-compose >=1.6.0 is required

First get a [docker-compose.yml](https://github.com/factoriotools/factorio-docker/blob/master/docker/docker-compose.yml) file. To get it from this repository:

```shell
git clone https://github.com/factoriotools/factorio-docker.git
cd factorio-docker/docker
```

Or make your own:

```yaml
version: '2'
services:
  factorio:
    image: factoriotools/factorio
    ports:
     - "34197:34197/udp"
     - "27015:27015/tcp"
    volumes:
     - /opt/factorio:/factorio
```

Now cd to the directory with docker-compose.yml and run:

```shell
sudo mkdir -p /opt/factorio
sudo chown 845:845 /opt/factorio
sudo docker-compose up -d
```

### Ports

* `34197/udp` - Game server (required). This can be changed with the `PORT` environment variable.
* `27015/tcp` - RCON (optional).

## LAN Games

Ensure the `lan` setting in server-settings.json is `true`.

```json
  "visibility":
  {
    "public": false,
    "lan": true
  },
```

Start the container with the `--network=host` option so clients can automatically find LAN games. Refer to the Quick Start to create the `/opt/factorio` directory.

```shell
sudo docker run -d \
  --network=host \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -v /opt/factorio:/factorio \
  --name factorio \
  --restart=unless-stopped  \
  factoriotools/factorio
```

## Deploy to other plaforms

### Vagrant

[Vagrant](https://www.vagrantup.com/) is a easy way to setup a virtual machine (VM) to run Docker. The [Factorio Vagrant box repository](https://github.com/dtandersen/factorio-lan-vagrant) contains a sample Vagrantfile.

For LAN games the VM needs an internal IP in order for clients to connect. One way to do this is with a public network. The VM uses DHCP to acquire an IP address. The VM must also forward port 34197.

```ruby
  config.vm.network "public_network"
  config.vm.network "forwarded_port", guest: 34197, host: 34197
```

### Amazon Web Services (AWS) Deployment

If you're looking for a simple way to deploy this to the Amazon Web Services Cloud, check out the [Factorio Server Deployment (CloudFormation) repository](https://github.com/m-chandler/factorio-spot-pricing). This repository contains a CloudFormation template that will get you up and running in AWS in a matter of minutes. Optionally it uses Spot Pricing so the server is very cheap, and you can easily turn it off when not in use.

## Using a reverse proxy

If you need to use a reverse proxy you can use the following nginx snippet:

```
stream {
  server {
      listen 34197 udp reuseport;
      proxy_pass my.upstream.host:34197;
  }
}
```

If your factorio host uses multiple IP addresses (very common with IPv6), you might additionally need to bind Factorio to a single IP (otherwise the UDP proxy might get confused with IP mismatches). To do that pass the `BIND` envvar to the container: `docker run --network=host -e BIND=2a02:1234::5678 ...`

## Troubleshooting

### My server is listed in the server browser, but nobody can connect

Check the logs. If there is the line `Own address is RIGHT IP:WRONG PORT`, then this could be caused by the Docker proxy. If the the IP and port is correct it's probably a port forwarding or firewall issue instead.

By default, Docker routes traffic through a proxy. The proxy changes the source UDP port, so the wrong port is detected. See the forum post *[Incorrect port detected for docker hosted server](https://forums.factorio.com/viewtopic.php?f=49&t=35255)* for details.

To fix the incorrect port, start the Docker service with the `--userland-proxy=false` switch. Docker will route traffic with iptables rules instead of a proxy. Add the switch to the `DOCKER_OPTS` environment variable or `ExecStart` in the Docker systemd service definition. The specifics vary by operating system.

### When I run a server on a port besides 34197 nobody can connect from the server browser

Use the `PORT` environment variable to start the server on the a different port, .e.g. `docker run -e "PORT=34198"`. This changes the source port on the packets used for port detection. `-p 34198:34197` works fine for private servers, but the server browser detects the wrong port.

## Contributors

* [dtandersen](https://github.com/dtandersen) - Maintainer
* [Fank](https://github.com/Fankserver) - Programmer of the Factorio watchdog that keeps the version up-to-date.
* [SuperSandro2000](https://github.com/supersandro2000) - CI Guy, Maintainer and runner of the Factorio watchdog. Contributed version updates and wrote the Travis scripts.
* [DBendit](https://github.com/DBendit/docker_factorio_server) - Coded admin list, ban list support and contributed version updates
* [Zopanix](https://github.com/zopanix/docker_factorio_server) - Original Author
* [Rfvgyhn](https://github.com/Rfvgyhn/docker-factorio) - Coded randomly generated RCON password
* [gnomus](https://github.com/gnomus/docker_factorio_server) - Coded white listing support
* [bplein](https://github.com/bplein/docker_factorio_server) - Coded scenario support
* [jaredledvina](https://github.com/jaredledvina/docker_factorio_server) - Contributed version updates
* [carlbennett](https://github.com/carlbennett) - Contributed version updates and bugfixes

[^1]: Space Age mods can also be individually enabled by using their name separated by space.  
  Example 1: Enable all by using `true`
  Example 2: Enable all by listing the mod names `space-age elevated-rails quality`  
  Example 3: Enable only Elevated rails `elevated-rails`
