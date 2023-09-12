apt update
apt -y install ansible
ansible-playbook -i 127.0.0.1 --connection=local install_containerd.yml
ansible-playbook -i 127.0.0.1 --connection=local install_kubeadm.yml
ansible-playbook -i 127.0.0.1 --connection=local install_bridge.yml
./up.sh