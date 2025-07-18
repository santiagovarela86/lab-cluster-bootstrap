#!/bin/bash
set -e

echo "[!] Destroying all Vagrant VMs..."
vagrant destroy -f --parallel

echo "[+] Bringing up fresh environment..."
vagrant up --parallel