FROM ubuntu:20.04

#### JAVA Installation #####
# Dockerfile base
# https://github.com/AdoptOpenJDK/openjdk-docker/blob/master/11/jdk/ubuntu/Dockerfile.hotspot.releases.full
###########################

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION jdk-11.0.11+9

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       aarch64|arm64) \
         ESUM='4966b0df9406b7041e14316e04c9579806832fafa02c5d3bd1842163b7f2353a'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.11_9.tar.gz'; \
         ;; \
       armhf|armv7l) \
         ESUM='2d7aba0b9ea287145ad437d4b3035fc84f7508e78c6fec99be4ff59fe1b6fc0d'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_arm_linux_hotspot_11.0.11_9.tar.gz'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='945b114bd0a617d742653ac1ae89d35384bf89389046a44681109cf8e4f4af91'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.11_9.tar.gz'; \
         ;; \
       s390x) \
         ESUM='5d81979d27d9d8b3ed5bca1a91fc899cbbfb3d907f445ee7329628105e92f52c'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.11_9.tar.gz'; \
         ;; \
       amd64|x86_64) \
         ESUM='e99b98f851541202ab64401594901e583b764e368814320eba442095251e78cb'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.11_9.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

#### Net Tools ####
RUN apt-get update \
    && apt-get -y install net-tools  \
    iputils-ping \
    iproute2 \
    lsof

###### OpendDayLight Instalation ######
ADD https://nexus.opendaylight.org/content/repositories/opendaylight.release/org/opendaylight/integration/opendaylight/15.1.0/opendaylight-15.1.0.tar.gz /tmp/odl.tar.gz
RUN tar -zxvf /tmp/odl.tar.gz -C /tmp
RUN mv /tmp/opendaylight-15.1.0 /app

###### OpendDayLight Setup ######
# Setup boot features
ENV ODL_FEATURES_DEFAULT=odl-restconf-all,odl-ovsdb-library,odl-restconf-all,odl-ovsdb-southbound-api,odl-ovsdb-southbound-impl,odl-ovsdb-southbound-impl-rest,features-openflowplugin
RUN echo '#!/bin/bash \n\
ODL_FEATURES_BOOT_INIT=$(grep -m1 "featuresBoot = " /app/etc/org.apache.karaf.features.cfg) \n\
ODL_FEATURES_BOOT_UPDATED="$(sed "s/=/=$ODL_FEATURES_DEFAULT,/g" <<< $ODL_FEATURES_BOOT_INIT)" \n\
echo $ODL_FEATURES_BOOT_UPDATED >> /app/etc/org.apache.karaf.features.cfg \n\
' > /tmp/init.sh
RUN chmod 755 /tmp/init.sh
RUN /tmp/init.sh

CMD ["/app/bin/karaf"]
