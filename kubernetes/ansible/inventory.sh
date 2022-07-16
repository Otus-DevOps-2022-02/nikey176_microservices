#!/bin/bash
echo 'Собираем информацию...'

TERRAFORM_DIR=../terraform

K8S_NODE_1=`terraform -chdir=$TERRAFORM_DIR show -json | jq '.values.outputs.external_ip_k8s_node_1.value'`
K8S_NODE_2=`terraform -chdir=$TERRAFORM_DIR show -json | jq '.values.outputs.external_ip_k8s_node_2.value'`

#K8S_NODE_1=`terraform show -json | jq '.values.root_module.resources[0].values.network_interface[0].nat_ip_address'`
#K8S_NODE_2=`terraform show -json | jq '.values.root_module.resources[1].values.network_interface[0].nat_ip_address'`

echo "{\"k8s-cluster\":{\"hosts\":{\"k8s-node-1\":{\"ansible_host\":$K8S_NODE_1},\"k8s-node-2\":{\"ansible_host\":$K8S_NODE_2}}},\"node-1\":{\"hosts\":{\"k8s-node-1\":{\"ansible_host\":$K8S_NODE_1}}},\"node-2\":{\"hosts\":{\"k8s-node-2\":{\"ansible_host\":$K8S_NODE_2}}}}" | jq > inventory.json
