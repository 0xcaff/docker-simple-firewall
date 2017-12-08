#!/bin/sh

if ping -c 1 -w 1 8.8.8.8
then
  echo "FAILED! Was able to ping google from behind the firewall."
  exit 1
fi

if ! nc -z -w 1 52.218.200.155 80
then
  echo "FAILED! Was able not able to reach the allowed server."
  exit 1
fi

echo "SUCCESS! The firewall was configured sucessfully."
