#!/bin/bash 

set -euo pipefail 

#Setting up Jenkins server" 
echo "Setting up Jenkins server..."

docker exec -u root jenkins_master bash -c "
set -e 

apt-get update &&
apt-get install -y docker.io npm &&
docker --version &&

apt-get install -y python3-venv
python3 -m venv venv
source venv/bin/activate
pip install checkov
checkov version

chown root:docker /var/run/docker.sock &&
chmod 660 /var/run/docker.sock &&
ls -l /var/run/docker.sock &&
usermod -aG docker jenkins &&

npm --version &&
npm install -g snyk &&
snyk --version &&

mkdir -p ~/.docker/cli-plugins &&
curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh &&
docker scout version

curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | bash &&
kubescape version"

echo "restarting Jenkins server..."
docker restart jenkins_master
echo "installs complete ✅"
