#!/bin/bash
# Start/enable application-related services

systemctl enable httpd.service
systemctl start httpd.service
