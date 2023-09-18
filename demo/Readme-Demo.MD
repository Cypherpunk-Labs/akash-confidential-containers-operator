# Quickstart Demo resources

In this folder you will find a collection of scripts and playbooks that will help get started with Akash and to demo the confidential containers feature.
All my testing was done against ubuntu 22.04 LTS.
To create a kubernetes cluster via kubeadm run the setup.sh in the ansible folder, this will be an all in one single node cluster for simplicity.
Then run install-akash.sh and install-kata-vanilla.sh from this demo folder. 
Now you can install the operator manager and our operator from the root of this project.
I used GCP for some testing and Ubuntu cloud-init for baremetal (I will do more on this at a later time).

---

# GCP Create Nested virtualisation image

as per REF: https://github.com/kata-containers/kata-containers/blob/main/docs/install/gce-installation-guide.md

SOURCE_IMAGE_PROJECT=ubuntu-os-cloud
SOURCE_IMAGE_FAMILY=ubuntu-2204-lts
IMAGE_NAME=${SOURCE_IMAGE_FAMILY}-nested


gcloud compute images create \
    --source-image-project $SOURCE_IMAGE_PROJECT \
    --source-image-family $SOURCE_IMAGE_FAMILY \
    --licenses=https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx \
    $IMAGE_NAME

---

# GCP Create VM instance

  gcloud compute instances create \
    --machine-type n1-standard-4 \
    --min-cpu-platform "Intel Broadwell" \
    --create-disk=auto-delete=yes,boot=yes,device-name=dsk-kata-testing,image=projects/artful-patrol-390412/global/images/ubuntu-2204-lts-nested,mode=rw,size=100,type=projects/artful-patrol-390412/zones/europe-west2-c/diskTypes/pd-balanced \
    --zone=europe-west2-c \
    kata-testing

---

# GCP firewal rules
gcloud compute --project=artful-patrol-390412 firewall-rules create akash --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80,tcp:443,tcp:8443,tcp:30000-32767,udp:30000-32767 --source-ranges=0.0.0.0/0

---

 _______               _     _       _                      _             
(_______)             | |   | |     | |                 _  (_)            
    _  ____ ___  _   _| |__ | |  ___| |__   ___   ___ _| |_ _ ____   ____ 
   | |/ ___) _ \| | | |  _ \| | /___)  _ \ / _ \ / _ (_   _) |  _ \ / _  |
   | | |  | |_| | |_| | |_) ) ||___ | | | | |_| | |_| || |_| | | | ( (_| |
   |_|_|   \___/|____/|____/ \_|___/|_| |_|\___/ \___/  \__)_|_| |_|\___ |
                                                                   (_____|

---

# coreDNS, pod will not resolve dns queries

coreDNS pod resolution problems. seems to work ok from host and debug logs shows request getting to dns.
So only pods trying to use 
  kubectl exec -ti busybox -- nslookup google.com 10.96.0.10
would time out. if we use the coreDNS pod ip instead of clusterIP it works, and the pod can resolve external dns like 8.8.8.8.
Only when I run the following will it work as expected.
  sudo modprobe br_netfilter
  sudo sysctl -p
now it should resolve properly. The anisible was changed from community.general.modprobe: to modprobe: which seems like it failed to apply on ubuntu 22.04 so have reverted back.
TODO: retest

```
  apiVersion: v1
  kind: Pod
  metadata:
    name: busybox
    namespace: default
  spec:
    containers:
    - image: busybox
      command:
        - sleep
        - "3600"
      imagePullPolicy: IfNotPresent
      name: busybox
    restartPolicy: Always
```

---

# helm install failed

...
Connection to rpc.sandbox-01.aksh.pw (216.153.62.49) 443 port [tcp/*] succeeded!
...
Last block Akash RPC https://rpc.sandbox-01.aksh.pw:443 seen was 8 seconds ago => OK
...
Error: rpc error: code = InvalidArgument desc = invalid provider: address not found: invalid request
...
Could not find provider:  on the blockchain when querying Akash RPC node: https://rpc.sandbox-01.aksh.pw:443
Attempting to create a new provider ...
Error: rpc error: code = NotFound desc = rpc error: code = NotFound desc = account akash1yxj968trypsmhj4wqeml7tdp2s0dtrdhmc5kqs not found: key not found
...
Error: rpc error: code = InvalidArgument desc = invalid provider: address not found: invalid request
...
Error: rpc error: code = NotFound desc = rpc error: code = NotFound desc = account akash1yxj968trypsmhj4wqeml7tdp2s0dtrdhmc5kqs not found: key not found
...
No valid certificate found for provider: akash1yxj968trypsmhj4wqeml7tdp2s0dtrdhmc5kqs
...
Error: rpc error: code = NotFound desc = rpc error: code = NotFound desc = account akash1yxj968trypsmhj4wqeml7tdp2s0dtrdhmc5kqs not found: key not found


## Cause, no account on chain, resolution use faucet to fund account, or fund account if mainnet

---

# kata pods not scheduling

Still getting '0/1 nodes are available: 1 Insufficient cpu. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.'
Bumped up from n1-standard-2 to n1-standard-4 and Pod would schedule this time. 

---

Tested with std VM and failed as needs VM flag in image.
Tested against Nested VM successfully for Kata, failed with coco

GCP E2 (e2-medium) Ubuntu 22.04 LTS

uname -a
Linux test-node04 6.2.0-1013-gcp #13~22.04.1-Ubuntu SMP Wed Aug 30 20:41:15 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

ansible-playbook 2.10.8
  config file = None
  configured module search path = ['/home/cypherpunkgcp01/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 3.10.12 (main, Jun 11 2023, 05:26:28) [GCC 11.4.0]

kubectl describe pod php-apache-kata-dragonball-XXX

Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  2m3s (x19 over 92m)  default-scheduler  0/1 nodes are available: 1 Insufficient cpu. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.

---

Tested against but failed for Kata and coco

GCP N2D (n2d-standard-2) x86/64 (Confidential VM service:TRUE)

uname -a
Linux crypt-node05 5.4.0-1021-gcp-fips #21+fips1-Ubuntu SMP Mon Dec 13 21:03:55 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux

ansible-playbook 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/cypherpunkgcp01/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 3.8.10 (default, May 26 2023, 14:05:08) [GCC 9.4.0]

kubectl describe pod php-apache-kata-dragonball-XXX
Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  2m44s  default-scheduler  0/1 nodes are available: 1 Insufficient cpu. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.

  https://github.com/kata-containers/kata-containers/issues/7919

---