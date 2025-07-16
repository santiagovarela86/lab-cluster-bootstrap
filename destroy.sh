#!/bin/bash
set -e

echo "[!] Destroying all Vagrant VMs..."
vagrant destroy -f
rm shared -r -f