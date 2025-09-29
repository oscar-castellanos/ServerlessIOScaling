# ServerlessIOScaling

This project provides a disk I/O scaling mechanism for workloads executed in containers. It is integrated into the serverless platform [ServerlessYARN](https://github.com/UDC-GAC/ServerlessYARN) as a forked repository.

The mechanism provides a serverless environment that supports Singularity/Apptainer containers, dynamically scaling their allocated disk I/O bandwidth based on real-time usage.

The ServerlessYARN platform may be deployed either on an existing physical cluster or on a virtual cluster for testing purposes. It also includes automated deployment through Infrastructure-as-Code (IaC) tools such as Ansible, along with a web interface for simplified management.

By leveraging the I/O scaling mechanism, containers can be automatically deployed across the available infrastructure and disks, taking into account the current contention of each node and disk.

## Getting Started

### Prerequisites

#### For the virtual cluster deployment

- Vagrant
- VirtualBox
- Vagrant plugins: vagrant-hostmanager, vagrant-reload, vagrant-vbguest

> vagrant-reload plugin is only necessary when deploying nodes with cgroups V1

You may install the vagrant plugins with the following commands:
```
vagrant plugin install vagrant-hostmanager
vagrant plugin install vagrant-reload
vagrant plugin install vagrant-vbguest
```

#### For the physical cluster deployment

- Python
- Ansible
- Passwordless SSH login between nodes

> Only one cluster node (i.e. master node) needs to have Ansible installed and a passwordless SSH login to the remaining ones

### Quickstart
The serverless platform need to be installed and deployed on the master node (or "server" node), while the containers will be deployed on the remaining cluster nodes (workers or "hosts").

- You can clone this repository and the required frameworks with
    ```
    git clone --recurse-submodules https://github.com/oscar-castellanos/ServerlessIOScaling.git
    ```

- Once cloned, change directory to the root directory
    ```
    cd ServerlessIOScaling
    ```

- Modify the files in **ansible/provisioning/config/modules** to customize your environment.
    > 02-hosts.yml and 04-disk.yml are the most relevant for the I/O scaling mechanism

- You may deploy the virtual cluster with Vagrant (if needed):
    ```
    vagrant up
    ```

- Inside the server node (you can use "vagrant ssh" to log in when using a virtual cluster) go to the **"ansible/provisioning"** directory within the platform root directory (accessible from **"/vagrant"** on the virtual cluster). Then, execute the scripts to install and set up all the necessary requirements for the platform and start its services:
    ```
    ansible-playbook load_config_playbook.yml
    python3 scripts/load_inventory_from_conf.py
    bash scripts/start_all.sh
    ```

**NOTE**: When deploying on a physical cluster that relies on SLURM for job scheduling, you can skip the execution of the **"load_inventory_from_conf.py"** script. The Ansible inventory will be automatically generated considering the available nodes. A sample script for sbatch is provided in the **"slurm"** directory.


- Once you are done, you can shutdown the virtual cluster (if applicable) exiting the server node and executing:
    ```
    vagrant halt
    ```

- Or you may destroy the whole virtual cluster with:
    ```
    vagrant destroy --force
    ```

### Web Interface

Once done with the installation and launch, you can visit the web interface in your browser in *{server-ip}*:9000/ui (or the port specified in the config file instead of 9000 if modified).

You will see a Home page with 5 subpages:
- **Containers**: here you can see and manage all the deployed containers
- **Hosts**: here you can see and manage all hosts as well as their containers
- **Apps**: here you can see and manage all apps as well as their associated containers
- **Services**: here you can see and manage all services of the platform
- **Rules**: here you can see and manage all scaling rules that are followed by the services

## Used tools
- [Vagrant](https://www.vagrantup.com/) - IaC tool for deploying the virtual cluster
- [VirtualBox](https://www.virtualbox.org) - VM Software to support the machines of the cluster
- [Ansible](https://www.ansible.com/) - Configuration Management Tool
- [Apptainer](https://apptainer.org/) - Singularity/Apptainer Containers management tool
- [Django](https://www.djangoproject.com/) - Web development framework
- [Python](https://www.python.org) - Programming language
- [Serverless Containers](https://bdwatchdog.dec.udc.es/serverless/) - Container resource scaling framework
- [BDWatchdog](https://bdwatchdog.dec.udc.es/monitoring/) - Resource monitoring framework


## Authors

* **&Oacute;scar Castellanos-Rodr&iacute;guez** (https://gac.udc.es/~oscar.castellanos/)
* **Roberto R. Exp&oacute;sito** (https://gac.udc.es/~rober/)
* **Jonatan Enes** (https://gac.udc.es/~jonatan/)
* **Juan Touriño** (https://gac.udc.es/~juan/)

## License
This project is distributed as free software and is publicly available under the GNU GPLv3 license (see the [LICENSE](LICENSE) file for more details).
