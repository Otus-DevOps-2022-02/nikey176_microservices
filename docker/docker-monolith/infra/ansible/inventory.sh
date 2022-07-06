#!/bin/bash
echo 'Собираем информацию...'

ANSIBLE_DIR=.
TERRAFORM_DIR=../terraform

HOST_NAME=`terraform -chdir=../terraform/ show -json | jq '.values.outputs.hostname.value'`
HOST_ADDRESS=`terraform -chdir=../terraform/ show -json | jq '.values.outputs.external_ip_address_app.value'`

#stage(){
#cd $ANSIBLE_DIR
#echo -e "[docker-hosts]"
#echo -e "docker-reddit-1 ansible_ssh_host=51.250.86.24"
#echo -e "docker-reddit-2 ansible_ssh_host=51.250.83.151"
#} > inventory
#stage

stage(){
cd $ANSIBLE_DIR
echo -e "[docker-hosts]"
for (( i = 0; i < `terraform -chdir=../terraform/ show -json | jq '.values.outputs.external_ip_address_app.value | length'`; i++ ))
do
echo -e `terraform -chdir=../terraform/ show -json | jq -r --arg i $i ".values.outputs.hostname.value[$i]"` \
ansible_ssh_host=\
`terraform -chdir=../terraform/ show -json | jq -r --arg i $i ".values.outputs.external_ip_address_app.value[$i]"`
done
} > inventory
stage