#! /bin/bash

#INSTALLATION OF K8S IN CENTOS 7 VM - PART 2

swapoff -a

sed -i '/swap/d' /etc/fstab

setenforce 0

#Check status of SELinux again. It should be disabled
sestatus

#Update sysctl settings for Kubernetes networking

cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl  --system

#Install Docker
sudo yum install -y yum-utils
sudo yum-config-manager  --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

#Kubernetes Setup and add yum repository for that

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF


#check-Available Versions of kubeadm,kubelet,kubect.

yum -v list kubeadm --show-duplicates
yum -v list kubectl --show-duplicates
yum -v list kubelet --show-duplicates

#Install Kubernetes components

yum install kubelet-1.21.1-0 kubeadm-1.21.1-0 kubectl-1.21.1-0 -y
systemctl enable --now kubelet

# Run the Command To Initialize Kubernetes master-node

kubeadm init

# Run The Following commands after Initializing Master 

#To start using your cluster, you need to run the following as a regular user:

  #mkdir -p $HOME/.kube
  #sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  #sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Alternatively, if you are the root user, you can run:

#export KUBECONFIG=/etc/kubernetes/admin.conf

# APPLY THE CNI FOR MASTER-NODE COMMUNICATION

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml



#Error handling for CRI not running
#rm /etc/containerd/config.toml
#systemctl restart containerd
