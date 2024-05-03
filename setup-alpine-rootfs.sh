#!/bin/sh
set -eu

export PATH='/sbin:/usr/sbin:/bin:/usr/bin'
export SHELL='/bin/sh'

mkdir -p /root/extensions/ttyd
cat << EOF > /root/extensions/ttyd/manifest.json
{
        "title": "Remote web terminal (ttyd)",
        "description": "Uses port 5002; User root / ssh password"
}
EOF

echo "octoprint" > /root/.octoCredentials
cat << EOF > /root/extensions/ttyd/start.sh
#!/bin/sh
ttyd -p 5002 --credential root:\$(cat /root/.octoCredentials) bash
EOF

cat << EOF > /root/extensions/ttyd/kill.sh
#!/bin/sh
pkill ttyd
EOF
chmod +x /root/extensions/ttyd/start.sh
chmod +x /root/extensions/ttyd/kill.sh
chmod 777 /root/extensions/ttyd/start.sh
chmod 777 /root/extensions/ttyd/kill.sh

# create the user account
adduser -D -g "octoprint" octoprint

export HOME='/home/octoprint'

# switch to octoprint user
su -s /bin/bash -c "python3 -m venv ~/octoprint-venv" octoprint
su -s /bin/bash -c ". ~/octoprint-venv/bin/activate && cd /mnt/octoprint-release && pip3 install ." octoprint
