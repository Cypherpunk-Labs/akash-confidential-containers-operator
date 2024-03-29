apt update
apt -y install ansible
ansible-galaxy collection install ansible.posix
ansible-playbook -i 127.0.0.1 --connection=local install_containerd.yml
ansible-playbook -i 127.0.0.1 --connection=local install_kubeadm.yml
ansible-playbook -i 127.0.0.1 --connection=local install_bridge.yml
sudo ./up.sh

## This block fails to apply
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
## Above two needed to get all-in-one to schedule, commented below as not sure it is needed
#kubectl label $(kubectl get nodes -o name) node-role.kubernetes.io/worker=