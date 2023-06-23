#!/bin/sh
set -e

nix build

rsync -Lavz result/ atalii@192.168.0.102:/home/atalii/images/
