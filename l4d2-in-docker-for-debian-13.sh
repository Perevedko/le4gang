#!/usr/bin/env bash

if [ -z "${STEAM_GROUP_ID}" ]; then
        echo 'Please set $STEAM_GROUP_ID'
fi

grep -oE "^#PasswordAuthentication yes" /etc/ssh/sshd_config \
  && sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config \
  && systemctl restart sshd

apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
apt update
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
 tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update
apt upgrade -y
apt install -y docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

docker pull left4devops/l4d2

if [ -z "${STEAM_GROUP_ID}" ]; then
	echo 'Please set $STEAM_GROUP_ID'
	exit 1
fi

NAME="BRATLAND"
PASSWORD="bratland"
DEFAULT_MAP="c14m1_junkyard"
EUROPE_REGION="3"
MOTD_CONTENT="НА ЭТОМ СЕРВЕРЕ ДАЮТ ПИЗДЫ И НЕ СТАВЯТ В ХУЙ"
BANDWITH_ARGS="+sv_minrate 5000 +sv_maxrate 25000 +sv_mincmdrate 10 +sv_maxcmdrate 33"
EXTRA_ARGS="$BANDWITH_ARGS"

docker run \
        --name l4d2 \
	--network host \
	--restart unless-stopped \
	-e HOSTNAME="$NAME" \
	-e DEFAULT_MAP="$DEFAULT_MAP" \
	-e MOTD=1 \
	-e MOTD_CONTENT="$MOTD_CONTENT" \
	-e STEAM_GROUP="$STEAM_GROUP_ID" \
	-e STEAM_GROUP_EXCLUSIVE=true \
	-e REGION="$EUROPE_REGION" \
	-e DEFAULT_MODE=versus \
	-e GAME_TYPES=versus \
	-e RCON_PASSWORD="$PASSWORD" \
	-e EXTRA_ARGS="$EXTRA_ARGS" \
	left4devops/l4d2 2>/dev/null | grep Network

