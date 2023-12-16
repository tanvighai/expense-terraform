#!/bin/bash
#first specify what type of file it is


dnf install python3.11-pip -y
pip3.11 install boto3 botocore
ansible-pull -localhost , -U https://github.com/tanvighai/infra-ansible.git main.yml -e role_name=${role_name}