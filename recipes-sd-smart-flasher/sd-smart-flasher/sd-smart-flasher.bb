SUMMARY = "A bash script for flashing the connected device SD card using a smart plug and sd-mux device."

RDEPENDS_${PN} = "bash"

SRC_URI = "file://smart-flash.sh"

LICENSE="Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/smart-flash.sh;md5=b90f7c91f339ed403fcc1bf4ddf543ed"

#This package doesn't have any files for the rootfs in it, option needed to create an empty
# package so when the rootfs image is made it finds the mksd_xxx.deb package and doesn't complain
#FILES_${PN} = ""
#ALLOW_EMPTY_${PN} = "1"

do_install() {
        install -Dm 0755 ${WORKDIR}/smart-flash.sh ${D}/${bindir}/smart-flash.sh
}

