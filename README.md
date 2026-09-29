# star-fetcher

A small, dependency-free, neofetch-like system information tool written in
**Ruby**. It is built for openSUSE devices (Leap, Tumbleweed, MicroOS) but
degrades gracefully anywhere `/proc` and `/etc/os-release` exist.

It is the fetching component used by
[star-fish-config](https://github.com/Nauclerus/star-fish-config).

## Requirements

- Ruby 3.4 or newer (tested on 4.0) — stdlib only, no gems
- Linux with `/proc` and `/etc/os-release`

## Installation

### From a release (recommended)

Download the latest `star-fetcher-<version>.gem` from the
[releases page](https://github.com/Nauclerus/star-fetcher/releases), then:

```console
$ gem install ./star-fetcher-0.1.0.gem
```

### From source

```console
$ git clone https://github.com/Nauclerus/star-fetcher.git
$ cd star-fetcher
$ gem build star-fetcher.gemspec
$ gem install ./star-fetcher-0.1.0.gem
```

## Usage

```console
$ bin/star-fetcher
```

```
user@host
---------
          ====             OS: openSUSE Leap 16.0
         ======            Host: WSL2
       ==== ====+          Kernel: 6.18.33.2-microsoft-standard-WSL2
     +====    +====        Uptime: 2h 32m
   +===+        ====       Packages: 1284 (rpm)
  ====            ====     Shell: fish
+===               +====   CPU: 11th Gen Intel(R) Core(TM) i5-1145G7 @ 2.60GHz (8)
====               +====   Memory: 3.4 GiB / 7.7 GiB
 =====            ====     Disk (/): 21.0 GiB / 250.0 GiB
   +===+        =====      Local IP: 172.20.10.2
==+  =====    +===+  ===   Locale: en_US.UTF-8
====   ==== =====  =====   Timezone: Europe/Brussels
...
```

### Options

```
-l, --logo NAME     Use a specific ASCII logo (see --list-logos)
    --list-logos    List the bundled logos and exit
    --no-color      Disable colored output
-h, --help          Show help
-v, --version       Show the version
```

Color is enabled automatically when standard output is a terminal.

## Logos

The following openSUSE variants are bundled:
`opensuse`, `opensuse_small`, `opensuse_leap`, `opensuse_tumbleweed`,
`opensuse_tumbleweed_small`, `opensuse_microos`.

The variant is selected automatically from `/etc/os-release`. Re-download the
artwork at any time with:

```console
$ scripts/scrape-ascii.sh
```

## Credits

The ASCII artwork is sourced from the excellent
[**fastfetch**](https://github.com/fastfetch-cli/fastfetch) project (MIT
licensed). See [NOTICE](NOTICE) for the full upstream license text.

The general look and layout are inspired by
[neofetch](https://github.com/dylanaraps/neofetch) (also MIT, now archived).

## License

AGPL-3.0-or-later. See [LICENSE](LICENSE).

Copyright (c) 2026 Wolf Van den Zegel
