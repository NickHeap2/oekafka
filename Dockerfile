#FROM repo/wincore-oe:0.1
FROM oe117-mpro:0.1

# new oe executable
COPY _progres /usr/dlc/bin/

# kafka libraries
COPY liboekafka-wrapper.so.1 /usr/dlc/lib/
COPY centos7-librdkafka.so /usr/dlc/lib/librdkafka.so.1
# make links
RUN ln -s /usr/dlc/lib/liboekafka-wrapper.so.1 /usr/dlc/lib/liboekafka-wrapper.so && \
 ln -s /usr/dlc/lib/librdkafka.so.1 /usr/dlc/lib/librdkafka.so

# app code
#COPY src/ /var/lib/openedge/code/
COPY buil/oe11/pl/ /var/lib/openedge/code/

ENV PROPATH="/var/lib/openedge/code/app.pl:/var/lib/openedge/code/:/var/lib/openedge/base/"

## testing
#ENV LD_LIBRARY_PATH=/usr/dlc/lib/
#COPY *-test /var/lib/openedge/code/
#COPY qa-dhlparcel-co-uk.cer /var/lib/openedge/code/
#COPY test /var/lib/openedge/code/
#COPY logging.config /var/lib/openedge/code/
