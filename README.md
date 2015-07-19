# Salt Master for Continuous Integration

This is a simple Salt Master docker container that should only be used for Continuous Integration, local development, etc. as it is (intentionally) highly insecure.

Derived from https://registry.hub.docker.com/u/jacksoncage/salt/dockerfile/

# Salt Minion

We have a separate Salt Minion docker file that you can find in the registry.

# What it does

Sets up a simple Salt Master with ZeroMQ transport and enables API access via HTTP.

# Users

API: `remotesalt`
SSH: `root` or `salt`

Note: the Salt Master runs as `root` to allow API access

# Environment Variables

 - `SALT_VERSION`: version of salt to install, default: 2014.7.4
 - `SALT_PASSWORD`: the password that will be used for any accounts
 - `LOG_LEVEL`: log level that the master will output with
 - `SALT_NAME`: minion name, defaults to to master

# Volumes
 - `/etc/salt` - Master/Minion config
 - `/var/cache/salt` - job data cache
 - `/var/logs/salt` - logs
 - `/srv/salt` - states, pillar reactors
