#!/bin/sh

# Sets up a restrictive outbound ipv4 firewall only allowing traffic to one
# destination (address, protocol, port, ip address). It is only a ipv4 firewall
# because docker (17.10.0-ce) only supports ipv6 behind a flag.

# Exit on first non-zero exit code like a sane language.
set -e

echo "Initializing Firewall"

sleep 1

# Clear output table.
iptables --flush OUTPUT

# Drop unmatched traffic.
iptables --policy OUTPUT DROP

# Allows traffic corresponding to inbound traffic.
iptables \
  --append OUTPUT \
  --match conntrack \
  --ctstate ESTABLISHED,RELATED \
  --jump ACCEPT

# Accept traffic to the loopback interface.
iptables \
  --append OUTPUT \
  --out-interface lo \
  --jump ACCEPT

# Accept traffic to tunnel interfaces.
iptables \
  --append OUTPUT \
  --out-interface tap0 \
  --jump ACCEPT

iptables \
  --append OUTPUT \
  --out-interface tun0 \
  --jump ACCEPT

# Accept traffic to vpn server.
iptables \
  --append OUTPUT \
  --destination "${ALLOW_IP_ADDRESS}" \
  --protocol "${ALLOW_PROTO}" \
  --dport "${ALLOW_PORT}" \
  --jump ACCEPT

# Accept local traffic to docker network. It doesn't seem possible to use the
# --realm flag in this iptables.

# The local address range routed by the eth0 interface.
docker_network=$(ip -o addr show dev eth0 | awk '$3 == "inet" {print $4}')

iptables \
  --append OUTPUT \
  --destination ${docker_network} \
  --jump ACCEPT

echo "Firewall Initialized"

# Accept connections on port to signal that the firewall is up. `-l` is for
# listen. `-k` is to keep the connection open after the first client disconnects
# and `-p` is to specify the port. Netcat can only handle one connection at a
# time.
nc -l -k -p $FIREWALL_READY_SIGNAL_PORT localhost
