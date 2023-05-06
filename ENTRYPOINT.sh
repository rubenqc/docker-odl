#!/usr/bin/env bash

###### Opendaylight Setup ######
# Define boot features
ODL_FEATURES_DEFAULT=odl-restconf-all,odl-ovsdb-library,odl-restconf-all,odl-ovsdb-southbound-api,odl-ovsdb-southbound-impl-ui,odl-ovsdb-southbound-impl,odl-ovsdb-southbound-impl-rest,features-openflowplugin

# Setup boot features
ODL_FEATURES_BOOT_INIT=$(grep -m1 "featuresBoot = " /app/etc/org.apache.karaf.features.cfg)
ODL_FEATURES_BOOT_UPDATED="$(sed "s/=/=$ODL_FEATURES_DEFAULT,/g" <<< $ODL_FEATURES_BOOT_INIT)"
echo $ODL_FEATURES_BOOT_UPDATED >> /app/etc/org.apache.karaf.features.cfg

###### Opendaylight Start ######
/app/bin/karaf
