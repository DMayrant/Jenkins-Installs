#!/bin/bash 

set -euo pipefail 

echo "Setting up Jenkins server..."

docker exec -u root jenkins_master bash -c "
set -e 

apt-get update &&
apt-get install -y docker.io npm python3-pip curl wget unzip pipx &&

# Terraform (idempotent)
if ! command -v terraform &> /dev/null; then
  wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip &&
  unzip terraform_1.6.6_linux_amd64.zip &&
  mv terraform /usr/local/bin/
fi &&

# Kubectl and Dependencies 
apt update && apt install -y curl apt-transport-https ca-certificates &&

curl -LO https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl &&
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl &&
kubectl version --client

# Containerd and Kind (Kind is lightweight and best for CI/CD pipelines)
apt update && apt install -y containerd &&
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64 &&
chmod +x ./kind &&
mv ./kind /usr/local/bin/kind

# Checkov via pipx (clean)
pipx install checkov &&
checkov --version &&

# Docker permissions
chown root:docker /var/run/docker.sock &&
chmod 660 /var/run/docker.sock &&
usermod -aG docker jenkins &&

# Snyk
npm install -g snyk &&
snyk --version &&

# Docker Scout
mkdir -p ~/.docker/cli-plugins &&
curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh &&
docker scout version &&

# Kubescape
curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | bash &&
kubescape version
"

echo "Restarting Jenkins..."
docker restart jenkins_master

echo "Setup complete ✅"
