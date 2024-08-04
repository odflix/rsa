#!/bin/bash

# Header Info
echo -e "Loading..."
APP="ngrokrdp"
var_disk="2"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="12"

# Variables
NEXTID=$(pvesh get /cluster/nextid)
NSAPP="ngrokrdp-lxc-$NEXTID"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Catch Errors
function catch_errors() {
  if [ "$?" -ne "0" ]; then
    echo -e "${RED}An error occurred. Exiting...${NC}"
    exit 1
  fi
}

# Default Settings
function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

# Echo default settings
function echo_default() {
  echo -e "${GREEN}Default settings:${NC}"
  echo -e "  CT_TYPE: $CT_TYPE"
  echo -e "  PW: $PW"
  echo -e "  CT_ID: $CT_ID"
  echo -e "  HN: $HN"
  echo -e "  DISK_SIZE: $DISK_SIZE"
  echo -e "  CORE_COUNT: $CORE_COUNT"
  echo -e "  RAM_SIZE: $RAM_SIZE"
  echo -e "  BRG: $BRG"
  echo -e "  NET: $NET"
  echo -e "  GATE: $GATE"
  echo -e "  APT_CACHER: $APT_CACHER"
  echo -e "  APT_CACHER_IP: $APT_CACHER_IP"
  echo -e "  DISABLEIP6: $DISABLEIP6"
  echo -e "  MTU: $MTU"
  echo -e "  SD: $SD"
  echo -e "  NS: $NS"
  echo -e "  MAC: $MAC"
  echo -e "  VLAN: $VLAN"
  echo -e "  SSH: $SSH"
  echo -e "  VERB: $VERB"
}

# Create LXC Container
function create_lxc() {
  echo -e "${YELLOW}Creating LXC container with ID $CT_ID...${NC}"
  # Command to create the LXC container
  pct create $CT_ID local:vztmpl/debian-$var_version-standard_12.0-1_amd64.tar.gz \
    -hostname $HN \
    -storage local-lvm \
    -rootfs $DISK_SIZE \
    -cores $CORE_COUNT \
    -memory $RAM_SIZE \
    -net0 name=eth0,bridge=$BRG,ip=$NET \
    --password $PW \
    --features nesting=1 \
    --ostype $var_os
  catch_errors
  echo -e "${GREEN}LXC container created successfully!${NC}"
}

# Main
default_settings
create_lxc
