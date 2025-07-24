FROM alpine:3.22 as builder
#FROM arm64v8/alpine:3.22 as builder

RUN \
  echo "###### INSTALLING DEPENDENCIES ##################" && \
  export arch=$(uname -m) && \
  apk --no-cache add curl g++ gcc git make sdl2-dev && \
  mkdir -p  /tmp/quake && \
  echo "###### FETCHING DEPENDENCIES ##################" && \
  git clone https://github.com/ioquake/ioq3 && \
  curl https://files.ioquake3.org/quake3-latest-pk3s.zip -o /tmp/quake/quake3-latest-pk3s.zip && \
  echo "###### BUILDING ##################" && \
  cd ioq3 && make && \
  echo "###### FINISHING STEPS ##################" && \
  unzip /tmp/quake/quake3-latest-pk3s.zip -d /tmp/quake && \
  if [ "$arch" = "x86_64" ]; then \
    cp -r /tmp/quake/quake3-latest-pk3s/* /ioq3/build/release-linux-x86_64/; \
  elif [ "$arch" = "aarch64" ]; then \
    cp -r /tmp/quake/quake3-latest-pk3s/* /ioq3/build/release-linux-arm64/; \
  else \
    echo "Unsupported architecture: $arch"; exit 1; \
  fi && \
  #cp -r /tmp/quake/quake3-latest-pk3s/* /ioq3/build/release-linux-arm64/ && \
  echo "###### FINISHED BUILDING ##################" 

FROM alpine:3.22
#FROM arm64v8/alpine:3.22
LABEL org.opencontainers.image.source="https://github.com/HeyyMrDJ/docker-k8s-quake3-server"
RUN adduser ioq3srv -D
RUN echo "test6"
#COPY --from=builder /ioq3/build/release-linux-${TARGETARCH} /home/ioq3srv
COPY --from=builder /ioq3/build/ /tmp/build/
COPY ./docker-quake3.sh /home/ioq3srv/baseq3/docker-quake3.sh
COPY ./server.cfg /home/ioq3srv/baseq3/server.cfg
RUN set -ex && \
    echo "###### COPYING FILES ##################" && \
    # Check if the ioq3 build directory exists and copy it
    if [ ! -d "/tmp/build" ]; then \
      echo "Build directory not found!"; exit 1; \
    fi && \
    # Find the ioq3 release directory and copy it to /home/ioq3srv
    echo "###### FINDING ioq3 release directory ##################" && \
    ioq3_path="$(find /tmp/build/ -type d -name 'release-linux-*')" && \
    echo "ioq3_path: $ioq3_path" && \
    mkdir -p /home/ioq3srv && \
    cp -r "$ioq3_path" /home/ioq3srv
    #chmod +x /home/ioq3srv/baseq3/docker-quake3.sh && \
    #chown -R ioq3srv:ioq3srv /home/ioq3srv/baseq3


    #RUN if [ "$TARGETARCH" = "amd64" ]; then \
#      mv /tmp/build/release-linux-x86_64 /home/ioq3srv; \
#    elif [ "$TARGETARCH" = "arm64" ]; then \
#      mv /tmp/build/release-linux-arm64 /home/ioq3srv; \
#    else \
#      echo "Unsupported arch: $TARGETARCH"; exit 1; \
#    fi
USER ioq3srv
EXPOSE 27960/udp
ENTRYPOINT ["/home/ioq3srv/baseq3/docker-quake3.sh"]
