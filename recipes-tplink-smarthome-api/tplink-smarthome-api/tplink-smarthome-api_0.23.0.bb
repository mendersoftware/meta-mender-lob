# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

SUMMARY = "TP-Link Smart Home API"
# WARNING: the following LICENSE and LIC_FILES_CHKSUM values are best guesses - it is
# your responsibility to verify that the values are complete and correct.
#
# The following license files were not able to be identified and are
# represented as "Unknown" below, you will need to check them yourself:
#   node_modules/lodash.isequal/LICENSE
#   node_modules/lodash.groupby/LICENSE
#   node_modules/lodash.defaultto/LICENSE
#
# NOTE: multiple licenses have been detected; they have been separated with &
# in the LICENSE value for now since it is a reasonable assumption that all
# of the licenses apply. If instead there is a choice between the multiple
# licenses then you should change the value to separate the licenses with |
# instead of &. If there is any doubt, check the accompanying documentation
# to determine which situation is applicable.
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=6284324a9e8299ec3f31b9ccf2262de3 \
                    file://node_modules/loglevel/LICENSE-MIT;md5=189bd989a70568ed30dff2262a1cf9a5 \
                    file://node_modules/tplink-smarthome-crypto/LICENSE;md5=992c881645d20336058c156835cc1b07 \
                    file://node_modules/lodash.isequal/LICENSE;md5=8f10c81975f996c3ba5b424884b4af96 \
                    file://node_modules/lodash.groupby/LICENSE;md5=a3b2b7770df62392c164de4001b59f8f \
                    file://node_modules/lodash.defaultto/LICENSE;md5=a3b2b7770df62392c164de4001b59f8f \
                    file://node_modules/commander/LICENSE;md5=25851d4d10d6611a12d5571dab945a00"

SRC_URI = "npm://registry.npmjs.org/;name=tplink-smarthome-api;version=${PV}"

NPM_SHRINKWRAP := "${THISDIR}/${PN}/npm-shrinkwrap.json"
NPM_LOCKDOWN := "${THISDIR}/${PN}/lockdown.json"

inherit npm

# Must be set after inherit npm since that itself sets S
S = "${WORKDIR}/npmpkg"
LICENSE_${PN}-commander = "MIT"
LICENSE_${PN}-lodash.defaultto = "MIT"
LICENSE_${PN}-lodash.groupby = "MIT"
LICENSE_${PN}-lodash.isequal = "MIT"
LICENSE_${PN}-loglevel = "MIT"
LICENSE_${PN}-tplink-smarthome-crypto = "MIT"
LICENSE_${PN} = "MIT"


