DESCRIPTION = "Samsung sd-mux tool for working with SD card multiplexer"

DEPENDS += "popt libftdi"
RDEPENDS_${PN} += "popt libftdi" 

TARGET_CC_ARCH_append = " -Wno-error=type-limits"
 
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=064ad0ceb0d2be1dd2e7fc4ba1b9de6f"

SRCREV = "ea1f8f0ed37aa60b624b082371cbb43d0da2678f"
SRC_URI = "git://git.tizen.org/tools/testlab/sd-mux;protocol=git"

S = "${WORKDIR}/git"

inherit cmake

