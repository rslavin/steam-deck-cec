#!/bin/bash

CEC_SLEEP_FILE_NAME="cec-sleep.service"
CEC_WAKE_FILE_NAME="cec-wake.service"

# create the sleep service file
cat <<EOF > "/etc/systemd/system/$CEC_SLEEP_FILE_NAME"
[Unit]
Description=CEC Sleep Command
Before=sleep.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cec-ctl -d/dev/cec0 -C
ExecStart=/usr/bin/cec-ctl -d/dev/cec0 --playback -o "Steam Deck"
ExecStart=/usr/bin/cec-ctl -d /dev/cec0 --to 0 --standby
ExecStart=/usr/bin/cec-ctl -d /dev/cec0 -C

[Install]
WantedBy=sleep.target
EOF

# create the wake service file
cat <<EOF > "/etc/systemd/system/$CEC_WAKE_FILE_NAME"
[Unit]
Description=CEC Wake Command
After=suspend.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cec-ctl -d/dev/cec0 -C
ExecStart=/usr/bin/cec-ctl -d/dev/cec0 --playback -o "Steam Deck"
ExecStart=/usr/bin/cec-ctl -d/dev/cec0 --to 0 --image-view-on
ExecStart=sleep 5
ExecStart=/usr/bin/cec-ctl -d/dev/cec0 --to 0 --active-source phys-addr=1.0.0.0
ExecStart=/usr/bin/cec-ctl -d/dev/cec0 -C

[Install]
WantedBy=suspend.target
EOF

# reload systemd to recognize the new services
systemctl daemon-reload

# enable the services to start at boot
systemctl enable "$CEC_SLEEP_FILE_NAME"
systemctl enable "$CEC_WAKE_FILE_NAME"

echo "Services $CEC_WAKE_FILE_NAME and $CEC_SLEEP_FILE_NAME have been installed and enabled."
