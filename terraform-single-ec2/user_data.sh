#!/bin/bash
set -xe

###########################################
# BASIC SYSTEM UPDATE
###########################################
dnf update -y
dnf install -y git curl tar gzip shadow-utils               # Basic tools

###########################################
# INSTALL PYTHON 3 + pip + venv
###########################################
dnf install -y python3 python3-pip python3-virtualenv

###########################################
# INSTALL NODE.JS 18 (Amazon Linux 2023 Way)
###########################################
dnf install -y nodejs-18 npm

###########################################
# CREATE APPLICATION DIRECTORY
###########################################
APP_DIR="/opt/awsec2assignment"
mkdir -p ${APP_DIR}
chown -R ec2-user:ec2-user ${APP_DIR}

###########################################
# CLONE YOUR REPOSITORY
###########################################
if [ -d "${APP_DIR}/AWSEC2Assignment" ]; then
  rm -rf "${APP_DIR}/AWSEC2Assignment"
fi

sudo -u ec2-user git clone https://github.com/rdhanore1/AWSEC2Assignment.git "${APP_DIR}/AWSEC2Assignment"


###########################################
# BACKEND (FLASK) SETUP
###########################################
BACKEND_DIR="${APP_DIR}/AWSEC2Assignment/DockerProject/backend"

if [ -d "${BACKEND_DIR}" ]; then
  sudo -u ec2-user python3 -m venv ${BACKEND_DIR}/venv

  source ${BACKEND_DIR}/venv/bin/activate

  if [ -f "${BACKEND_DIR}/requirements.txt" ]; then
    sudo -u ec2-user ${BACKEND_DIR}/venv/bin/pip install --upgrade pip
    sudo -u ec2-user ${BACKEND_DIR}/venv/bin/pip install -r ${BACKEND_DIR}/requirements.txt
  else
    sudo -u ec2-user ${BACKEND_DIR}/venv/bin/pip install flask flask-cors
  fi
fi


###########################################
# FRONTEND (EXPRESS) SETUP
###########################################
FRONTEND_DIR="${APP_DIR}/AWSEC2Assignment/DockerProject/frontend"

if [ -d "${FRONTEND_DIR}" ]; then
  cd "${FRONTEND_DIR}"
  sudo -u ec2-user npm install
fi


###########################################
# SYSTEMD SERVICE → FLASK BACKEND
###########################################
cat > /etc/systemd/system/awsec2-backend.service <<'EOF'
[Unit]
Description=AWSEC2Assignment Flask Backend
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/opt/awsec2assignment/AWSEC2Assignment/DockerProject/backend
Environment=PATH=/opt/awsec2assignment/AWSEC2Assignment/DockerProject/backend/venv/bin
ExecStart=/opt/awsec2assignment/AWSEC2Assignment/DockerProject/backend/venv/bin/python app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


###########################################
# SYSTEMD SERVICE → EXPRESS FRONTEND
###########################################
cat > /etc/systemd/system/awsec2-frontend.service <<'EOF'
[Unit]
Description=AWSEC2Assignment Express Frontend
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/opt/awsec2assignment/AWSEC2Assignment/DockerProject/frontend
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


###########################################
# ENABLE + START SERVICES
###########################################
systemctl daemon-reload
systemctl enable awsec2-backend.service
systemctl enable awsec2-frontend.service

systemctl start awsec2-backend.service
systemctl start awsec2-frontend.service


###########################################
# FINAL LOGGING
###########################################
echo "Setup completed successfully at $(date)" > /var/log/awsec2_setup.log
journalctl -u awsec2-backend --no-pager -n 50 >> /var/log/awsec2_setup.log || true
journalctl -u awsec2-frontend --no-pager -n 50 >> /var/log/awsec2_setup.log || true
