#!/bin/bash

ip link add dummy0 type dummy
ip link set dev dummy0 up
ip addr add 169.254.1.1/32 dev dummy0
ip link set dev dummy0 up
ip addr show dev dummy0

