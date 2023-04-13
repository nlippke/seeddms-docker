# Information

Builds a docker image for seeddms (https://www.seeddms.org).

This image supports OCR processing for images and PDFs out of the box. Other types can be configured and converted using web interface.
Cron is also included to handle jobs internally (backup, index, ...).

## How to run

`docker run --name seeddms -d -v dms-data:/var/www/seeddms/data -p 8080:80 nlippke/seeddms:6.0.23`

or as compose file

```yaml
version: '3'

services:
  dms:
    image: nlippke/seeddms:6.0.23
    ports:
      - "8080:80"
      - "8443:443"
    environment:
      - TZ=Europe/Berlin
      - 'CRON_SCHEDULER=5 * * * *'
      - 'CRON_INDEX=0 0 * * *'
      - 'CRON_BACKUP=0 23 * * *'
      - SSL_PORT=8443
      - FORCE_SSL=1
    mem_limit: 2g
    volumes:
      - dms-data:/var/www/seeddms/data
      - /share/Container/container-data/seeddms/extensions:/var/www/seeddms/seeddms/ext
      - /share/Container/container-data/seeddms/backup:/var/www/seeddms/backup
      - /share/Container/container-data/seeddms/import:/var/www/seeddms/import
    logging:
      options:
        max-size: "10m"
        max-file: "1"
volumes:
  dms-data:
```

If you run for the first time make sure to call `/install` and follow the instructions there.


## Environment Variables
Variable               | Default Value | Description
-----------------------|-----------------------------------|------------
`PUBLIC_CERT`          |`/var/www/seeddms/conf/cacert.pem` |the fully qualified container path for the CA certificate
`PUBLIC_CERT_SUBJ`     |`/CN=localhost`                    |the subject used if the CA certificate is created
`PRIVATE_KEY`          |`/var/www/seeddms/conf/cakey.pem`  |the fully qualified container path for the private certificate key
`FORCE_SSL`            |`0`                                |`1` redirects to https if plain request
`SSL_PORT`             |`443`                              |must match external port for https requests

## Default configuration

The image is preconfigured. Nevertheless you're guided through the installation steps upon first start for a review.

1. `/var/www/seeddms/data` is the central data directory. It is not intended to be bound to a host directory. Instead use a docker volume.
2. `/var/www/seeddms/backup` is where backups are being stored. Bind it to a host directory.
3. `var/www/seeddms/import` is being used as drop folder. Bind it to a host directory.
4. Optionally mount `/var/www/seeddms/seeddms/ext` to allow upload of extensions.

Backup and import directories should be readable/writeable by uid 33!

## Backup

Backup is done by syncing the `data` folder (partially) to the backup folder. Use environment variable `CRON_BACKUP` for automatic scheduling.

## Full text search

Indexing documents can take some time (especially on low powered NAS). Therefore indexing is done asynchronously by a job. Use `CRON_INDEX` for scheduling this job.

## Scheduler

seeddms comes with an internal scheduler. This scheduler itself is triggered using cron. Default configuration is to check every 5 minutes whether to fire a job.
This schedule can be changed using `CRON_SCHEDULER`. Also make sure that a seeddms-user `cli_scheduler` exists.

## Migrating from 5.1

If migrating from an existing 5.1 installation you need to update database first using [migration.sql](migration.sql).

## Additional information

The image is base on https://github.com/ludwigprager/docker-seeddms.
