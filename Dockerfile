#FROM repo/wincore-oe:0.1
FROM oe117-mpro:0.1

USER root

# libssl dependency
RUN yum install -y openssl librdkafka jansson.x86_64 snappy.x86_64 boost.x86_64 && \
    yum clean all && \
    rm -rf /var/cache/yum

USER 1000

# kafka libraries
COPY liboekafka-wrapper.so.1 librdkafka.so.1 libserdes.so.1 libavro.so.23.0.0 libavrocpp.so.1.8.0.0 /usr/dlc/lib/
#COPY centos7-librdkafka.so /usr/dlc/lib/librdkafka.so.1
#centos7-librdkafka.so /usr/dlc/lib/librdkafka.so.1
# make links
RUN ln -s /usr/dlc/lib/liboekafka-wrapper.so.1 /usr/dlc/lib/liboekafka-wrapper.so \
 && ln -s /usr/dlc/lib/librdkafka.so.1 /usr/dlc/lib/librdkafka.so \
 && ln -s /usr/dlc/lib/libserdes.so.1 /usr/dlc/lib/libserdes.so

# ln -s /usr/dlc/lib/librdkafka.so.1 /usr/dlc/lib/librdkafka.so
# ln -s /lib64/librdkafka.so.1 /usr/dlc/lib/librdkafka.so

ENV PROPATH=""


## testing
#ENV LD_LIBRARY_PATH=/usr/dlc/lib/
#COPY *-test /var/lib/openedge/code/
#COPY qa-dhlparcel-co-uk.cer /var/lib/openedge/code/
#COPY test /var/lib/openedge/code/
#COPY logging.config /var/lib/openedge/code/

# testing add test procedures
COPY src/ /var/lib/openedge/code/

# app code
COPY build/oe11pl/OEKafka.pl /var/lib/openedge/code/oekafka/
COPY build/ablcontainer/oe11pl/* /var/lib/openedge/code/ablcontainer/

#RUN yum install -y librdkafka

#COPY producer-test consumer-test combined-test /var/lib/openedge/code/

#ENV MPRO_STARTUP=' -param "BATCH" -b -p "/var/lib/openedge/code/ablcontainer/ABLContainer.pl<<ABLContainer/start.r>>" -rereadnolock'
ENV MPRO_STARTUP=' -param "BATCH" -b -q -p ablcontainer/start.r -rereadnolock'
ENV BOOTSTRAP_PROPATH="ablcontainer/ABLContainer.pl,ablcontainer/OpenEdge.Core.pl"
