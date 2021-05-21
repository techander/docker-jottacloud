# Dockerized Jottacloud Client
Docker of Jottacloud client side backup daemon with jotta-cli and jottad inside.

Jottacloud is a Cloud Storage (backup) service provider, which offers [unlimited storage space](https://www.jottacloud.com/en/pricing.html) for personal use. It also has lifetime plan.

## Repository
- GitHub: [bluet/docker-jottacloud](https://github.com/bluet/docker-jottacloud/)
- DockerHub: [bluet/jottacloud](https://hub.docker.com/r/bluet/jottacloud)

```
docker pull bluet/jottacloud
```

## Use
`docker run bluet/jottacloud`
```
docker run \
   -e JOTTA_TOKEN=XXXXX \
   -e JOTTA_DEVICE=YYYY \
   -e JOTTA_SCANINTERVAL=1h \
   -e LOCALTIME=ZZZ/ZZZ \
   -v /data/jottacloud/config:/var/lib/jottad \
   -v /data/jottacloud/.ignore:/config/.ignore
   -v /home/:/backup/home \
   bluet/jottacloud \
   jottacloud
```

## Volume mount-point
Path | Description
------------ | -------------
/var/lib/jottad/ | Config and data. In order to keep login status and track backup progress, please use a persistent volume.
/backup/ | Data you want to backup. ex,  `~/foo/ => /backup/foo`, `/etc/ => /backup/etc/`, or just `/volume1/ => /backup/`.

## ENV
Name | Value
------------ | -------------
JOTTA_TOKEN | Your `Personal login token`. Please obtain it from Jottacloud dashboard [Settings -> Security](https://www.jottacloud.com/web/secure). This will only show once and can only be used in a short time, so please use persistent valume on `/var/lib/jottad/` to save your login status.
JOTTA_DEVICE | Device name of the backup machine.  Used for identifying which machine these backup data belongs to.
JOTTA_SCANINTERVAL | Interval time of the scan-and-backup. Can be `1h`, `30m`, or `0` for realtime monitoing.
LOCALTIME | Local timezone. ex, `Aisa/Taipei`

## Exclude / Ignore files/folders from being backup (and waste cloud space)
- Global excludes
   - Mount a file to `/config/ignorefile` and it'll be parsed.
   - Mount or edit `/config/.ignore` directly.
 - Folder specific excludes
  - Put a `.jottaignore` in that folder.

**NOTE**: Adding a new pattern will also apply to files already backup. If you already have a backup which contains `/foo/bar/` and later adds a new pattern `bar/` in ignore list, the `bar/` folder will be removed from all your previous backups and moved to Trash.

### Syntax / Pattern
`.ignore`, `ignorefile`, and `.jottaignore` are `.gitignore` compatible.  You can check templates in [github/gitignore](https://github.com/github/gitignore) or use [Gitignore.io](https://gitignore.io) to generate one for you.

## Result
![2021-05-21 09-37-19 的螢幕擷圖](https://user-images.githubusercontent.com/51141/119069168-32407a80-ba18-11eb-824d-82a60d13437a.png)

# Detailed official configuration guide of jotta-cli
- [Jottacloud CLI Configuration
](https://docs.jottacloud.com/en/articles/2750154-jottacloud-cli-configuration)
- [Ignoring files and folders from backup with Jottacloud CLI](https://docs.jottacloud.com/en/articles/1437235-ignoring-files-and-folders-from-backup-with-jottacloud-cli)

## Credit
This is a fork with fixes from [maaximal/jottadocker](https://github.com/maaximal/jottadocker)
