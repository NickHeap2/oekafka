#FROM repo/wincore-oe:0.1
FROM oe117-mpro:0.1

RUN yum install -y openssl && \
    yum clean all && \
    rm -rf /var/cache/yum

#RUN yum install -y librdkafka-devel && \
#RUN yum install -y cyrus-sasl-lib && \
#    yum clean all && \
#    rm -rf /var/cache/yum && \
#    ln -s /lib64/libsasl2.so.3 /lib64/libsasl2.so.2
#libssl.so.1.0.0

#COPY build/assemblies/ assemblies/

COPY liboekafka-wrapper.so /usr/dlc/lib/
COPY centos7-librdkafka.so /usr/dlc/lib/librdkafka.so
COPY centos7-librdkafka.so /usr/dlc/lib/librdkafka.so.1

ENV LD_LIBRARY_PATH=/usr/dlc/lib/
COPY *-test /var/lib/openedge/code/


COPY src/ /var/lib/openedge/code/

ENV MPRO_STARTUP=" -b -p combinedtest.p" \
    display_banner=no

COPY logging.config /var/lib/openedge/code/
