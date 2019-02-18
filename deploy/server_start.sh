#!/bin/bash
# Start/enable application-related services

sudo systemctl is-enabled --quiet httpd \
    || sudo systemctl enable httpd

sudo systemctl is-active --quiet httpd \
    || sudo systemctl start httpd
