Mender Lord of the Boards
=========================

*"One Board to rule them all, One Board to find them,  
One Board to bring them all and in the darkness bind them  
In the Land of Mender where the Shadows lie."*


The repository contains a Yocto meta layer for testing the Mender images on the hardware. For the tests we are
using [tp-link HS100 smart plug device](https://www.tp-link.com/us/products/details/cat-5516_HS100.html) and [API](https://www.npmjs.com/package/tplink-smarthome-api) (for switching the tested device power on and off) and [sd-mux tool](https://wiki.tizen.org/SD_MUX/manpage) developed by Samsung.

RPi3 B+ board is used for managing the power and flashing SD cards of all the boards connected used in Mender HW testing.

SD image smart flashing Tool
============================

Mender smart flasher software is used for replacing the SD images of all the boards used during HW testing. The ordinary set of steps for flashing the SD card of the running device is as follows:

* first we need to discover the smart plug we are using and switch the device power off
* once the device is off we need to discover the sd-mux device and switch the SD card into "test server" mode
* having the sd-mux device connected in the "test server" mode we need to replace the content of the sd-card with the new sd image we will use for testing
* once everything above is done we are changing the SD card mode to the "device under test" and we are plugging the tested board on
* we enjoy using the freshly flashed device for running the tests using it

All the above is happening without unplugging the SD card.


![Mender logo](https://mender.io/user/pages/resources/06.digital-assets/mender.io.png)

## Getting started

To start using smart flashing tool create a Yocto image containing this layer together with some dependencies. Example configuration of bblayers.conf and local.conf used for building a RPi3 image (core-image-full-cmdline) used in our in-house testing looks like below.

### bblayers.conf

```bash
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
  /home/jenkins/poky/meta \
  /home/jenkins/poky/meta-poky \
  /home/jenkins/poky/meta-yocto-bsp \
  /home/jenkins/meta-mender/meta-mender-core \
  /home/jenkins/meta-mender/meta-mender-raspberrypi \
  /home/jenkins/meta-raspberrypi \
  /home/jenkins/meta-openembedded/meta-oe \
  /home/jenkins/meta-openembedded/meta-multimedia \
  /home/jenkins/meta-openembedded/meta-networking \
  /home/jenkins/meta-openembedded/meta-python \
  /home/jenkins/meta-mender-lob \
  /home/jenkins/meta-mender/meta-mender-demo \
  /home/jenkins/meta-mender/meta-mender-raspberrypi-demo \
  "
```

### local.conf additions

```bash
MACHINE ??= "raspberrypi3"

INHERIT += "rm_work"

# The name of the disk image and Artifact that will be built.
# This is what the device will report that it is running, and different updates must have different names
# because Mender will skip installation of an Artifact if it is already installed.
MENDER_ARTIFACT_NAME = "lob-0.1"

INHERIT += "mender-full"

# For Raspberry Pi, uncomment the following block:
RPI_USE_U_BOOT = "1"
MENDER_BOOT_PART_SIZE_MB = "40"
IMAGE_INSTALL_append = " kernel-image kernel-devicetree"
IMAGE_FSTYPES_remove += " rpi-sdimg"

# Yocto Sumo (2.5) or newer
MENDER_PARTITION_ALIGNMENT = "4194304"

# Build for Hosted Mender
# To get your tenant token, log in to https://hosted.mender.io,
# click your email at the top right and then "My organization".
# Remember to remove the meta-mender-demo layer (if you have added it).
# We recommend Mender 1.7.0b1 and Yocto Project's pyro or later for Hosted Mender.
#
MENDER_SERVER_URL = "https://hosted.mender.io"
MENDER_TENANT_TOKEN = "<YOUR-HOSTED-MENDER-TENANT-TOKEN>"

MENDER_DEMO_WIFI_SSID ?= <YOUR-SSID>
MENDER_DEMO_WIFI_PASSKEY ?= <YOUR-WIFI-PASSWD>

# The following settings to enable systemd are needed for all Yocto
# releases sumo and older.  Newer releases have these settings conditionally
# based on the MENDER_FEATURES settings and the inherit of mender-full above.
DISTRO_FEATURES_append = " systemd"
VIRTUAL-RUNTIME_init_manager = "systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED = "sysvinit"
VIRTUAL-RUNTIME_initscripts = ""

ARTIFACTIMG_FSTYPE = "ext4"
```

## Contributing

We welcome and ask for your contribution. If you would like to contribute, please read our guide on how to best get started [contributing code or documentation](https://github.com/mendersoftware/mender/blob/master/CONTRIBUTING.md).

## License

Mender is licensed under the Apache License, Version 2.0. See [LICENSE](https://github.com/mendersoftware/mender-crossbuild/blob/master/LICENSE) for the full license text.

## Security disclosure

We take security very seriously. If you come across any issue regarding
security, please disclose the information by sending an email to
[security@mender.io](security@mender.io). Please do not create a new public
issue. We thank you in advance for your cooperation.

## Connect with us

* Join the [Mender Hub discussion forum](https://hub.mender.io)
* Follow us on [Twitter](https://twitter.com/mender_io). Please
  feel free to tweet us questions.
* Fork us on [Github](https://github.com/mendersoftware)
* Create an issue in the [bugtracker](https://tracker.mender.io/projects/MEN)
* Email us at [contact@mender.io](mailto:contact@mender.io)
* Connect to the [#mender IRC channel on Freenode](http://webchat.freenode.net/?channels=mender)
