#!/bin/bash
set -e

echo "[!] Destroying all Vagrant VMs..."
vagrant destroy -f

echo "[!] Removing .vagrant state and shared token..."
rm -rf .vagrant/
rm -rf shared/
mkdir -p shared

echo "[+] Bringing up fresh environment..."
vagrant up
