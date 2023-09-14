Tested against 

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
as per REF: https://github.com/kata-containers/kata-containers/blob/main/docs/install/gce-installation-guide.md

SOURCE_IMAGE_PROJECT=ubuntu-os-cloud
SOURCE_IMAGE_FAMILY=ubuntu-2204-lts
IMAGE_NAME=${SOURCE_IMAGE_FAMILY}-nested


gcloud compute images create \
    --source-image-project $SOURCE_IMAGE_PROJECT \
    --source-image-family $SOURCE_IMAGE_FAMILY \
    --licenses=https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx \
    $IMAGE_NAME


  gcloud compute instances create \
    --machine-type n1-standard-4 \
    --min-cpu-platform "Intel Broadwell" \
    --create-disk=auto-delete=yes,boot=yes,device-name=dsk-kata-testing,image=projects/artful-patrol-390412/global/images/ubuntu-2204-lts-nested,mode=rw,size=100,type=projects/artful-patrol-390412/zones/europe-west2-c/diskTypes/pd-balanced \
    --zone=europe-west2-c \
    kata-testing

Still getting '0/1 nodes are available: 1 Insufficient cpu. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.'
Bumped up from n1-standard-2 to n1-standard-4 and Pod would schedule this time. 
 
---

coreDNS pod resolution problems. seems to work ok from host and debug logs shows request getting to dns.
So only pods trying to use 
  kubectl exec -ti busybox -- nslookup google.com 10.96.0.10
time out. if we use the pod ip instead of clusterIP it works, and the pod can resolve external dns.
Only when I run 
  sudo modprobe br_netfilter
  sudo sysctl -p
will it begin to resolv properly.