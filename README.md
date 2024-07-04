# rkhunter-manage

Rootkit Hunter management script

## Context

Based on this [article](https://www.getpagespeed.com/server-setup/security/sane-use-of-rkhunter-in-centos-7) I wanted to make something useful for everyone not matter the linux distro they are using.

As I did something pretty similar for the [Vuls](https://github.com/future-architect/vuls) project named [vuls-manage](https://github.com/Jiab77/vuls-scripts/blob/master/native/vuls-manage.sh), why not doing same for [Rootkit Hunter](http://rkhunter.sourceforge.net/)?

Here is how [rkhunter-manage](rkhunter-manage.sh) is born.

## Installation

```bash
# Get the latest version of the script
wget https://raw.githubusercontent.com/Jiab77/rkhunter-manage/main/rkhunter-manage.sh -O rkhunter-manage.sh

# Make the script executable
chmod -v +x rkhunter-manage.sh

# Install globally (optional)
sudo mv -v rkhunter-manage.sh /usr/local/bin/rkhunter-manage
```

> When installed globally, the `.sh` extension is removed for convenience. You can then call the script simply by typing `rkhunter-manage`.

## Usage

```console
$ rkhunter-manage

Rootkit Hunter management script / Jiab77 - 2021

Usage: rkhunter-manage <action>
  configure         - Configure existing Rootkit Hunter installation
  restore           - Restore RootKit Hunter configuration from backup file
  update            - Download and update Rootkit Hunter database files
  scan              - Run Rootkit Hunter scan
  scan-from-cron    - Run Rootkit Hunter scan from CRON
  show-log          - Show log from last scan
  help              - Show help
```

> The `scan` option will enable tests that are disabled by default for some reasons. This will make the scan more longer than usual but __it's an expected behavior__.

## Initialization

Before running the initial scan, you must configure `rkhunter` and download latest database files.

Here is how to do it:

1. `rkhunter-manage` __configure__
2. `rkhunter-manage` __update__
3. `rkhunter-manage` __scan__

> If you want to restore the original `rkhunter` config, simply run `rkhunter-manage` __restore__.

## Credit

* [@Jiab77](https://github.com/jiab77)
