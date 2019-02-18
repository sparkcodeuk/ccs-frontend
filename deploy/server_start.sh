#!/bin/bash
# Start/enable application-related services

systemctl is-enabled --quiet httpd \
    || systemctl enable httpd.service

systemctl is-active --quiet httpd \
    || systemctl start httpd.service
