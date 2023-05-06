FROM openjdk:18

USER root
WORKDIR /root

COPY ENTRYPOINT.sh /

###### OpendDayLight Instalation ######
ADD https://nexus.opendaylight.org/content/repositories/opendaylight.release/org/opendaylight/integration/karaf/0.18.0/karaf-0.18.0.tar.gz /tmp/odl.tar.gz
RUN tar -zxvf /tmp/odl.tar.gz -C /tmp
RUN mv /tmp/karaf-0.18.0 /app

ENTRYPOINT ["/ENTRYPOINT.sh"]