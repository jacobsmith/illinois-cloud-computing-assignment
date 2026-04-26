#!/bin/bash

# Start ovsdb-server (allow modprobe failures — OVS may be built into the
# linuxkit kernel rather than available as a loadable module)
service openvswitch-switch start || true

# Wait for ovsdb-server socket to appear
for i in $(seq 1 10); do
    [ -S /var/run/openvswitch/db.sock ] && break
    sleep 0.5
done

# Start ovs-vswitchd if the init script didn't (it skips it when modprobe fails)
if ! pgrep -x ovs-vswitchd > /dev/null; then
    echo "Starting ovs-vswitchd manually..."
    ovs-vswitchd unix:/var/run/openvswitch/db.sock \
        --pidfile=/var/run/openvswitch/ovs-vswitchd.pid \
        --detach \
        --log-file=/var/log/openvswitch/ovs-vswitchd.log \
        && echo "ovs-vswitchd started" \
        || echo "ovs-vswitchd failed — check /var/log/openvswitch/ovs-vswitchd.log"
fi

exec "$@"
