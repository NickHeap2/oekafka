#FROM repo/wincore-oe:0.1
FROM oe117-mpro:0.1

# libssl dependency
RUN yum install -y openssl librdkafka jansson.x86_64 snappy.x86_64 boost.x86_64 && \
    yum clean all && \
    rm -rf /var/cache/yum

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


ENV PROPATH="/var/lib/openedge/code/app.pl:/var/lib/openedge/code/:/var/lib/openedge/base/"

## testing
#ENV LD_LIBRARY_PATH=/usr/dlc/lib/
#COPY *-test /var/lib/openedge/code/
#COPY qa-dhlparcel-co-uk.cer /var/lib/openedge/code/
#COPY test /var/lib/openedge/code/
#COPY logging.config /var/lib/openedge/code/

# app code
#COPY src/ /var/lib/openedge/code/
COPY build/oe11/pl/app.pl /var/lib/openedge/code/

#RUN yum install -y librdkafka

COPY producer-test consumer-test combined-test /var/lib/openedge/code/
