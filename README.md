This utility is to pull a pfx cert out of a Traefik managed acme.json cert store file so it can be loaded into Plex (or anything else) in an automated way.  The container pulls the cert upon start and once a day thereafter via cron.

You can find a pre-built container on docker hub at `gregtakacs/acme2pfx`
Input environment variables:

`CERT_KEY_FILE`: The filename of the file that stores the password for the output p12 file. Rather than having the password in an environment variable we want a file location so we can use docker secrets (see example)

`CERT_DOMAIN`: The domain name of the certificate we're trying to pull

`CERT_RESOLVER`: The name of the certificate resolver the certificate is using in Traefik as it would determine where it's stored in the `acme.json` file

`TMP_DIR`: The directory where the intermediary key and cert files will be saved before they get combined into a password protected p12 file. They do get deleted at the end of the process but they're in memory/disk for a little bit. These are in unencrypted format, so it's best to have these stored in memory on a tmpfs rather than saving them to disk (see example).

You will also need two volumes mounted, one for source and one for destination.

Sample YAML:
```
version: "3.9"

########################### SECRETS
secrets:
  cert_key:
    #This file location is on the host machine
    file: /secrets/plex_cert_key

########################### SERVICES
services:

  acme2pfx:
    image: gregtakacs/acme2pfx
    container_name: acme2pfx
    secrets:
      - plex_cert_key
    environment:
      - CERT_KEY_FILE=/run/secrets/cert_key
      - CERT_DOMAIN=example.com
      - CERT_RESOLVER=dns-cloudflare
      - TMP_DIR=/var/cache
    tmpfs:
      - /var/cache # temporary place in memory to store extracted certs
    volumes:
      - $DOCKERDIR/appdata/traefik/acme:/source:ro # Mount traefik volume as read-only
      - $DOCKERDIR/appdata/traefik/acme:/dest # And whichever volume you want to output on
```