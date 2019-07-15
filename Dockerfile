# Pull base image.
FROM jlesage/baseimage:ubuntu-16.04

# Define working directory.
WORKDIR /tmp

RUN \
	apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
	echo "Adding bitcoin repository..." && \
	add-pkg --virtual build-dependencies \
		software-properties-common \
		&& \
	add-apt-repository ppa:bitcoin/bitcoin && \
    del-pkg build-dependencies && \
	add-pkg \
		# ravend dependencies
		# libboost_system.so.1.58.0
		libboost-system1.58.0 \
		# libboost_filesystem.so.1.58.0
		libboost-filesystem1.58.0 \
		# libboost_program_options.so.1.58.0
		libboost-program-options1.58.0 \
		# libboost_thread.so.1.58.0
		libboost-thread1.58.0 \
		# libboost_chrono.so.1.58.0
		libboost-chrono1.58.0 \
		# libdb_cxx-4.8.so
		libdb4.8++ \
		# libcrypto.so.1.0.0
		libssl-dev \
		# libevent_pthreads-2.0.so.5
		libevent-pthreads-2.0-5 \
		# libevent-2.0.so.5
		libevent-2.0-5 \
		# libzmq.so.5
		libzmq5 \
		# libstdc++.so.6
		libstdc++6 \
		# libgcc_s.so.1
		libgcc1 \
		# libpthread.so.0, libm.so.6, libc.so.6, librt.so.1, libdl.so.2
		libc6 \
		# libevent_core-2.0.so.5
		libevent-core-2.0-5 \
		# libsodium.so.18
		libsodium18 \
		#
		curl \
		wget \
		ca-certificates \
		tzdata \
		&& \
	rm -rf /tmp/* /tmp/.[!.]*

# Define ipfs
ARG IPFS_VERSION=0.4.21	
ARG IPFS_URL=https://dist.ipfs.io/go-ipfs/v${IPFS_VERSION}/go-ipfs_v${IPFS_VERSION}_linux-amd64.tar.gz

RUN \
	add-pkg cron && \
	(crontab -l ; echo " 0 1 * * * /sync_all_not_related_ipfs_hashes.sh >> /storage/.ipfs/ravencoinipfsbootstrapmirror.log") | crontab && \
	wget -q --show-progress --progress=bar:force:noscroll ${IPFS_URL} && \
	tar zxvf go-ipfs_v${IPFS_VERSION}_linux-amd64.tar.gz && \
	cp go-ipfs/ipfs /bin && \
	rm -rf /tmp/* /tmp/.[!.]*

# Define download URLs.
ARG RAVENCOIN_VERSION=2.4.0
ARG RAVENCOIN_URL=https://github.com/RavenProject/Ravencoin/archive/v${RAVENCOIN_VERSION}.tar.gz

RUN \
	echo "Make install RavencoinWallet..." && \
	add-pkg --virtual build-dependencies \
		build-essential \
		libtool \
		autotools-dev \
		automake \
		pkg-config \
		libssl-dev \
		libevent-dev \
		bsdmainutils \
		python3 \
		libprotobuf-dev \
		protobuf-compiler \
		libzmq3-dev \
		libdb4.8-dev \
		libdb4.8++-dev \
		libboost-system-dev \
		libboost-filesystem-dev \
		libboost-chrono-dev \
		libboost-program-options-dev \
		libboost-test-dev \
		libboost-thread-dev \
		&& \
	mkdir ravencoin && \
	echo "Download RavencoinWallet..." && \
	curl -sS -L ${RAVENCOIN_URL} | tar -xz --strip 1 -C ravencoin && \
	cd ravencoin && \
	./autogen.sh && \
	./configure --enable-cxx \
				--disable-shared \
				--without-gui \
				--disable-tests \
				--disable-bench \
				--with-pic CXXFLAGS="-fPIC -O2" CPPFLAGS="-fPIC -O2" \
				&& \
	make -j4 && \
	make install && \
	strip --strip-unneeded /usr/local/bin/ravend && \
	strip --strip-unneeded /usr/local/lib/libravenconsensus.a && \
	strip --strip-unneeded /usr/local/bin/raven-cli && \
    echo "Remove unused packages..." && \
    del-pkg build-dependencies && \
    apt-get purge --auto-remove xz-utils -y && \
	rm -rf /tmp/* /tmp/.[!.]*
	
# Add files
COPY rootfs/ /

# Set environment variables.
ENV	APP_NAME="RavencoinP2Pipfs"

# Define mountable directories.
VOLUME ["/storage"]

# Expose port
EXPOSE 8767 18770 8766 18766
# Swarm TCP; should be exposed to the public
EXPOSE 4001
# Daemon API; must not be exposed publicly but to client services under you control
EXPOSE 5001
# Web Gateway; can be exposed publicly with a proxy, e.g. as https://ipfs.example.org
EXPOSE 8080
# Swarm Websockets; must be exposed publicly when the node is listening using the websocket transport (/ipX/.../tcp/8081/ws).
EXPOSE 8081