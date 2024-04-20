Refer:
https://github.com/satzwebio/kubernetes-devops-security/blob/main/setup/vm-install-script/install-script.sh


#!/bin/bash

echo ".........----------------#################._.-.-INSTALL-.-._.#################----------------........."
PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '
echo "PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '" >> ~/.bashrc
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc
source ~/.bashrc

: '
#!/bin/bash: This is called a shebang line, and it specifies that the script should be executed using the Bash shell.
echo ".........----------------#################._.-.-INSTALL-.-._.#################----------------.........": This line prints a message to the terminal. It seems to be a header indicating that an installation process is occurring.
PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] ': This line sets the PS1 environment variable, which controls the prompt displayed in the terminal. This particular PS1 configuration seems to create a colorful prompt displaying the username (\u), hostname (\H), and current directory (\w), with various colors specified using ANSI escape sequences.
echo "PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '" >> ~/.bashrc: This line appends the PS1 configuration to the ~/.bashrc file, ensuring that the custom prompt will be set every time a new shell session is started.
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc: This line uses the sed command to edit the ~/.bashrc file in place (-i flag). It adds force_color_prompt=yes at the beginning of the file. This likely ensures that the colored prompt will always be displayed.
source ~/.bashrc: This line sources the ~/.bashrc file, applying the changes made to it immediately in the current shell session. This is done to ensure that the custom prompt is applied without needing to start a new shell session.
'



# Don't ask to restart services after apt update, just do it.
[ -f /etc/needrestart/needrestart.conf ] && sed -i 's/#\$nrconf{restart} = \x27i\x27/$nrconf{restart} = \x27a\x27/' /etc/needrestart/needrestart.conf

: '
[ -f /etc/needrestart/needrestart.conf ]: This checks if a file named needrestart.conf exists in the directory /etc/needrestart/. The brackets [ ] denote a conditional expression. -f checks if the given file exists and is a regular file.
&&: This is a logical AND operator in Bash. It means that the command following it will be executed only if the previous command (the file check) succeeds, i.e., if the file exists.
sed -i 's/#\$nrconf{restart} = \x27i\x27/$nrconf{restart} = \x27a\x27/' /etc/needrestart/needrestart.conf: This command uses sed (stream editor) to perform an in-place modification (-i flag) of the file /etc/needrestart/needrestart.conf. The s command in sed is used for substitution. It replaces occurrences of #$nrconf{restart} = 'i' with $nrconf{restart} = 'a'. The backslashes (\) before the dollar signs ($) and single quotes (') escape them, allowing sed to interpret them correctly. The # at the beginning of the pattern is a comment character in many configuration files and needs to be escaped to match it literally.
In summary, this script checks if a specific configuration file exists and, if it does, modifies it to change the restart behavior of the needrestart tool. Specifically, it changes the configuration from asking for confirmation before restarting services (i) to automatically restarting services (a).
'


apt-get autoremove -y  #removes the packages that are no longer needed
apt-get update
systemctl daemon-reload

: '
pt-get autoremove -y: This command removes packages that were automatically installed as dependencies for other packages but are no longer needed. The -y flag is used to automatically answer "yes" to all prompts, so the command runs without requiring manual confirmation.
apt-get update: This command updates the package lists for repositories configured in the system's package manager. It retrieves information about the latest versions of packages available for installation or upgrade.
systemctl daemon-reload: This command reloads systemd manager configuration. It's typically used after making changes to systemd unit files to ensure that systemd recognizes the changes. Reloading the daemon doesn't restart any services, but it does make systemd aware of any modifications to unit files.
'

KUBE_LATEST=$(curl -L -s https://dl.k8s.io/release/stable.txt | awk 'BEGIN { FS="." } { printf "%s.%s", $1, $2 }')
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /" >> /etc/apt/sources.list.d/kubernetes.list

:'
KUBE_LATEST=$(curl -L -s https://dl.k8s.io/release/stable.txt | awk 'BEGIN { FS="." } { printf "%s.%s", $1, $2 }'): This line retrieves the latest stable version of Kubernetes by querying the URL https://dl.k8s.io/release/stable.txt. It then uses awk to extract the major and minor version numbers and assigns them to the variable KUBE_LATEST.
mkdir -p /etc/apt/keyrings: This command creates the directory /etc/apt/keyrings if it doesn't already exist. This directory is typically used for storing trusted GPG keys used for package verification.
curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg: This line downloads the GPG public key for the Kubernetes repository corresponding to the determined version ($KUBE_LATEST). It then uses gpg to dearmor the key and save it as /etc/apt/keyrings/kubernetes-apt-keyring.gpg.
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /" >> /etc/apt/sources.list.d/kubernetes.list: This line appends a new entry to the /etc/apt/sources.list.d/kubernetes.list file. This entry specifies the Kubernetes repository URL along with the path to the GPG keyring file for package verification.

**more info on last line
echo: This command is used to print text to the standard output.
"deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /": This is the text that will be printed. It's a deb package repository entry that APT (Advanced Package Tool) understands. Let's break it down further:
deb: This specifies that the repository contains binary packages.
[signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg]: This part specifies the path to the GPG keyring file that will be used to verify the authenticity of the packages downloaded from this repository. It ensures that the packages are not tampered with during transit.
https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/: This is the URL of the Kubernetes repository. It includes the version of Kubernetes (${KUBE_LATEST}) determined earlier in the script.
/: This indicates the root directory of the repository.
>> /etc/apt/sources.list.d/kubernetes.list: This redirects the output of the echo command (the repository entry) and appends it to the file /etc/apt/sources.list.d/kubernetes.list. This file is included in APT's sources list and is used by APT to determine where to fetch packages from.
This step is necessary because it adds the Kubernetes repository to the list of package sources that APT knows about. Without this entry, APT wouldn't know where to find Kubernetes packages when you try to install or update them using APT commands like apt-get. Additionally, specifying the GPG keyring file ensures that APT verifies the integrity of the packages downloaded from this repository, enhancing security.
'



apt-get update
KUBE_VERSION=$(apt-cache madison kubeadm | head -1 | awk '{print $3}')
apt-get install -y docker.io vim build-essential jq python3-pip kubelet kubectl kubernetes-cni kubeadm containerd
pip3 install jc

:'
apt-get update: This command updates the package lists for repositories configured in the system's package manager. It ensures that the system has the latest information about available packages and versions.
KUBE_VERSION=$(apt-cache madison kubeadm | head -1 | awk '{print $3}'): This line retrieves the version of kubeadm available in the package repository. Here's a breakdown:
apt-cache madison kubeadm: This command queries the APT cache to retrieve information about the available versions of the kubeadm package.
| head -1: This pipes the output to head, which selects the first line of output. This is likely done to ensure that only the latest version is selected.
| awk '{print $3}': This pipes the output to awk, which selects the third column of output. This column contains the version number of kubeadm. The version is then assigned to the variable KUBE_VERSION.
apt-get install -y docker.io vim build-essential jq python3-pip kubelet kubectl kubernetes-cni kubeadm containerd: This line installs several packages required for setting up a Kubernetes environment. Here's what each package does:
docker.io: Docker is used for containerization.
vim: A text editor, which might be useful for configuration.
build-essential: Contains essential packages needed for building software from source.
jq: A lightweight and flexible command-line JSON processor.
python3-pip: The package manager for Python, required for installing Python packages.
kubelet: The primary node agent that runs on each node in the cluster.
kubectl: The command-line tool for interacting with the Kubernetes API server.
kubernetes-cni: Contains the Container Network Interface (CNI) plugins used for networking in Kubernetes.
kubeadm: A command-line utility for bootstrapping Kubernetes clusters.
containerd: An industry-standard container runtime.
pip3 install jc: This line installs the jc Python package using pip3. jc is likely used for formatting JSON data, which could be useful for scripting or interacting with Kubernetes APIs.
'


### UUID of VM
### comment below line if this Script is not executed on Cloud based VMs
jc dmidecode | jq .[1].values.uuid -r

:'
jc dmidecode: This command likely uses the jc tool to format the output of the dmidecode command. dmidecode is a command-line utility for displaying hardware information from the BIOS. It provides details about the systems hardware, including the UUID.
jq .[1].values.uuid -r: This part of the script uses jq to parse the formatted output of dmidecode and extract the UUID. Heres what each part does:
jq: jq is a lightweight and flexible command-line JSON processor.
.[1].values.uuid: This part of the jq expression navigates the JSON structure to access the UUID value. It assumes that the UUID is located at the second element ([1]) in the JSON array produced by dmidecode.
-r: This flag tells jq to output the result as raw text, without JSON formatting.
The script seems to be designed to be executed on a cloud-based VM, where the UUID can be useful for identifying and managing the instance. However, the comment indicates that it should only be executed on cloud-based VMs. This could be because the UUID might not be present or might not be useful on non-cloud-based systems, or because executing it on non-cloud-based systems could produce unexpected results or errors.

If this script is executed on a cloud-based VM, it will output the UUID of the VM. If its not executed on a cloud-based VM, it should be commented out to prevent unnecessary execution or errors.
'

systemctl enable kubelet

echo ".........----------------#################._.-.-KUBERNETES-.-._.#################----------------........."
rm -f /root/.kube/config
kubeadm reset -f

mkdir -p /etc/containerd
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' > /etc/containerd/config.toml
systemctl restart containerd

# uncomment below line if your host doesnt have minimum requirement of 2 CPU
# kubeadm init --pod-network-cidr '10.244.0.0/16' --service-cidr '10.96.0.0/16' --ignore-preflight-errors=NumCPU --skip-token-print
kubeadm init --pod-network-cidr '10.244.0.0/16' --service-cidr '10.96.0.0/16'  --skip-token-print

mkdir -p ~/.kube
cp -i /etc/kubernetes/admin.conf ~/.kube/config

kubectl apply -f "https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml"
kubectl rollout status daemonset weave-net -n kube-system --timeout=90s
sleep 5

echo "untaint controlplane node"
node=$(kubectl get nodes -o=jsonpath='{.items[0].metadata.name}')
for taint in $(kubectl get node $node -o jsonpath='{range .spec.taints[*]}{.key}{":"}{.effect}{"-"}{end}')
do
    kubectl taint node $node $taint
done
kubectl get nodes -o wide

:'
echo ".........----------------#################._.-.-KUBERNETES-.-._.#################----------------.........": This line prints a message indicating that Kubernetes setup is starting.
rm -f /root/.kube/config: This removes any existing Kubernetes configuration file for the root user to ensure a clean setup.
kubeadm reset -f: This resets the Kubernetes cluster configuration on the node, ensuring it's in a clean state before initialization.
mkdir -p /etc/containerd: This creates a directory for containerd configuration.
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' > /etc/containerd/config.toml: This command retrieves the default containerd configuration and modifies it to use systemd cgroups instead of the default configuration. It then saves this modified configuration to /etc/containerd/config.toml.
systemctl restart containerd: This restarts the containerd service to apply the new configuration.
kubeadm init --pod-network-cidr '10.244.0.0/16' --service-cidr '10.96.0.0/16' --skip-token-print: This initializes the Kubernetes control-plane node with the specified pod network CIDR and service CIDR. The --skip-token-print flag prevents printing the bootstrap token, which is typically used for securely joining worker nodes to the cluster.
mkdir -p ~/.kube: This creates a directory for the current user's Kubernetes configuration.
cp -i /etc/kubernetes/admin.conf ~/.kube/config: This copies the Kubernetes configuration file generated during initialization to the user's home directory, allowing kubectl commands to be run without needing root privileges.
kubectl apply -f "https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml": This applies the Weave Net CNI (Container Network Interface) plugin to the cluster. Weave Net is a popular choice for network plugin in Kubernetes clusters.
kubectl rollout status daemonset weave-net -n kube-system --timeout=90s: This waits for the Weave Net daemonset to be fully rolled out in the kube-system namespace, with a timeout of 90 seconds.
sleep 5: This command adds a brief delay to ensure that the previous operation has completed before proceeding.
echo "untaint controlplane node": This line prints a message indicating that the control plane node is being untainted.
The loop starting with node=$(kubectl get nodes -o=jsonpath='{.items[0].metadata.name}') untaints the control plane node by removing any taints that may prevent workloads from being scheduled on it.
the "-" indiates untaint.
kubectl get nodes -o wide: This command retrieves information about the nodes in the cluster and their status, including any taints that may still be present after untainting the control plane node.
'



echo ".........----------------#################._.-.-Docker-.-._.#################----------------........."

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker
systemctl enable docker

:'
echo ".........----------------#################._.-.-Docker-.-._.#################----------------.........": This line simply prints a message indicating that Docker configuration is being applied.
cat > /etc/docker/daemon.json <<EOF ... EOF: This command uses a here document (<<EOF ... EOF) to write JSON configuration to the file /etc/docker/daemon.json. The configuration specifies:
"exec-opts": ["native.cgroupdriver=systemd"]: Configures Docker to use systemd as the cgroup driver. This is necessary for running Docker in containers managed by Kubernetes.
"log-driver": "json-file": Sets the log driver to write Docker logs in JSON format to a file.
"storage-driver": "overlay2": Specifies the storage driver to use for Docker images and containers. overlay2 is a modern storage driver optimized for performance and stability.
mkdir -p /etc/systemd/system/docker.service.d: This command creates a directory to store additional systemd service configuration for Docker.
systemctl daemon-reload: This command reloads systemd manager configuration to ensure that any changes made to systemd unit files are recognized.
systemctl restart docker: This command restarts the Docker service to apply the new configuration.
systemctl enable docker: This command enables the Docker service to start automatically at boot time.
'


echo ".........----------------#################._.-.-Java and MAVEN-.-._.#################----------------........."
apt install openjdk-11-jdk maven -y
java -version
mvn -v

echo ".........----------------#################._.-.-JENKINS-.-._.#################----------------........."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
echo 'deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/' > /etc/apt/sources.list.d/jenkins.list
apt update
apt install -y jenkins
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins
usermod -a -G docker jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo ".........----------------#################._.-.-COMPLETED-.-._.#################----------------........."