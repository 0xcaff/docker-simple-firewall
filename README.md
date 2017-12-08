docker-simple-firewall
======================

A container which sets up a simple iptables firewall only allowing outbound
traffic to the docker local network and a single ip, port and protocol
combination. Once the firewall is ready, a TCP socket is opened to signal the
firewall is ready.

Usage
-----

First, start the firwall container.

    docker run \
      --name=firewall \
      --cap-add=NET_ADMIN \
      -e ALLOW_IP_ADDRESS=52.218.200.155 \
      -e ALLOW_PORT=80 \
      -e ALLOW_PROTO=tcp \
      0xcaff/simple-outbound-firewall

Then, connect another container to the firewall by sharing the firewall
container's network stack.

    docker run \
      --network="container:firewall" \
      -it \
      alpine:3.7

Checkout the [`example/`][example] folder to see an example of this with
docker-compose and waiting for the firewall to be ready before using the
network.

[example]: ./example
