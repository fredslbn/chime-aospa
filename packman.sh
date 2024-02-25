#!/bin/bash
pacman -Sy --needed --noconfirm archlinux-keyring
pacman -Syyu --needed --noconfirm wget base-devel xmlto inetutils bc cpio python-sphinx python-sphinx_rtd_theme graphviz imagemagick git python zip github-cli fortune-mod ccache jre8-openjdk
