#!/bin/bash
#first specify what type of file it is


dnf install python3.11-pip ansible -y | tee -a /opt/userdata.log
pip3.11 install boto3 botocore | tee -a /opt/userdata.log
ansible-pull -localhost , -U https://github.com/tanvighai/infra-ansible.git main.yml -e role_name=${role_name} | tee -a /opt/userdata.log