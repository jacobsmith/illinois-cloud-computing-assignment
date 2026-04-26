FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python2 \
    python2-dev \
    curl \
    build-essential \
    net-tools \
    iproute2 \
    iptables \
    iputils-ping \
    tcpdump \
    openvswitch-switch \
    openvswitch-testcontroller \
    php-cli \
    php-xmlrpc \
    memcached \
    iperf \
    iperf3 \
    libxml2-dev \
    libxslt1-dev \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 2
RUN curl -sS https://bootstrap.pypa.io/pip/2.7/get-pip.py | python2

# Make 'python' resolve to python2 (mininet scripts use /usr/bin/env python)
RUN ln -sf /usr/bin/python2 /usr/local/bin/python

WORKDIR /app

COPY ext/mininet /app/ext/mininet
COPY ext/ryu /app/ext/ryu
COPY minidc /app/minidc
COPY mdc /app/mdc
COPY resources /app/resources

# Install Mininet from bundled source
# Strip 'mininet.examples' from packages: the examples/ dir is at repo root,
# not inside the mininet/ subpackage, so setup.py's reference to it is broken.
# Also compile and install mnexec, the C helper binary that setup.py doesn't build.
RUN cd /app/ext/mininet && \
    sed -i "s/, 'mininet.examples'//" setup.py && \
    python2 setup.py install && \
    gcc -o mnexec mnexec.c && \
    install -m 755 mnexec /usr/local/bin/mnexec

# Install Ryu deps from its requirements file, then install Ryu
# Pin packages whose newer versions dropped Python 2 support:
#   PyYAML 5.4+ needs Cython on Python 2; greenlet 2.0+ dropped Python 2;
#   paramiko 2.10+ dropped Python 2; msgpack-python was renamed to msgpack.
# Pin oslo.config to 1.x (the old namespace-package style that ryu 3.19 was
# written against). Modern oslo.config (2.x+) installs as oslo_config and
# causes circular import errors when used with the old 'oslo.config.cfg' style.
RUN pip2 install \
    "PyYAML==5.3.1" \
    "greenlet==1.1.3" \
    "paramiko==2.9.5" \
    "eventlet==0.24.1" \
    lxml \
    netaddr \
    routes \
    six \
    webob \
    "stevedore==1.10.0" \
    "oslo.config==1.12.1" \
    msgpack \
    msgpack-python \
    tinyrpc \
    pbr
RUN cd /app/ext/ryu && python2 setup.py install

ENV PYTHONPATH=/app

RUN chmod +x /app/mdc

COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["/bin/bash"]
