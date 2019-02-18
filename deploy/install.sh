#!/bin/bash
# System init/update

echo "Starting codedeploy install.sh ..."

DEPLOY_PATH="/deploy"
WEB_PREV="/var/www.prev"
WEB_CURRENT="/var/www"

# Revert web files in the event of a deployment error
function rollback {
    echo -n "Rolling back deployment state: "
    if [ -e "$WEB_PREV" ]; then
        if [ -e "$WEB_CURRENT" ]; then
            sudo rm -rf "$WEB_CURRENT"
        fi

        sudo mv -f "$WEB_PREV" "$WEB_CURRENT"
    fi

    echo "done."
    exit 1
}

# Update existing software
cd /root
sudo yum update -y || rollback

# Ensure we have a clean webroot to deploy into
# @TODO check we can recover an in-place instance (move web root out the way rather than trashing it)

# Move the existing web root out the way & recreate
if [ -e "$WEB_CURRENT" ]; then
    sudo mv -f "$WEB_CURRENT" "$WEB_PREV"
    sudo mkdir -p "$WEB_CURRENT"
    sudo chown root:root "$WEB_CURRENT"
fi

# Add required package repos
# @TODO ADD TO BASE IMAGE
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm || true
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm || true

# Install required packages
# NOTE: ruby required by codedeploy agent

# ADD TO BASE IMAGE
# @TODO ADD TO BASE IMAGE
sudo yum -y install \
    httpd \
    ruby \
    php72u \
    php72u-mysqlnd.x86_64 \
    php72u-opcache \
    php72u-xml \
    php72u-gd \
    php72u-devel \
    php72u-intl \
    php72u-mbstring \
    php72u-bcmath \
    php72u-soap \
    php72u-json \
    || rollback

# Install CodeDeploy agent
# ADD TO BASE IMAGE
sudo curl -s -o install https://aws-codedeploy-eu-west-1.s3.amazonaws.com/latest/install || rollback
sudo chmod +x install
sudo ./install auto || rollback

# Prepare & move files into place
echo "-----------"
sudo find "$DEPLOY_PATH" -type f
echo "-----------"

sudo rm -f "$DEPLOY_PATH/appspec.yml"
sudo rm -rf "$DEPLOY_PATH/deploy"
sudo mv -f "$DEPLOY_PATH/"* "$WEB_CURRENT"
sudo ln -s "$WEB_CURRENT/public" "$WEB_CURRENT/html"

# Cleanup
if [ -e "$DEPLOY_PATH" ]; then
    sudo rm -rf "$DEPLOY_PATH"
fi

if [ -e "$WEB_PREV" ]; then
    sudo rm -rf "$WEB_PREV"
fi

echo "Codedeploy install.sh complete."
