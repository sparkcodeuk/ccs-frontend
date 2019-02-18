#!/bin/bash
# Stop application-related services

sudo systemctl is-active --quiet httpd \
    && sudo systemctl stop httpd.service
