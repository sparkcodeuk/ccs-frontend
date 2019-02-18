#!/bin/bash
# Stop application-related services

systemctl is-active --quiet httpd \
    && systemctl stop httpd.service
