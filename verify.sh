#!/bin/bash

## Create Resource Group for VM Scale Set
az group create -n zj-verify-vmss -l chinanorth

## Create VM Scale Set to 2000
for i in {1..2000}
do
	az group deployment create --name zj-verify-vmss-$i -g zj-verify-vmss --template-file vmss_template.json --parameters vmss_parameters.json --parameters "{\"vmSku\": {\"value\": \"Standard_A0\"}, \"vmssName\": {\"value\": \"zj-verify-vmss-$i\"}, \"pipLabel\": {\"value\": \"zj-verify-vmss-$i\"},\"pipName\": {\"value\": \"zj-verify-vmss-$i\"}}"
done

## Delete Resource Group for VM Scale Set
az group delete -n zj-verify-vmss -y

## Create Resource Group for VM Scale Set
az group create -n zj-verify-vmss-scale -l chinanorth

## Create each vmSku vmss for scale
az group deployment create --name verify-vmss-scale-a -g zj-verify-vmss-scale --template-file vmss_template.json --parameters vmss_parameters.json --parameters "{\"vmSku\": {\"value\": \"Standard_A0\"}, \"vmssName\": {\"value\": \"verify-vmss-scale-a\"}, \"pipLabel\": {\"value\": \"verify-vmss-scale-a\"},\"pipName\": {\"value\": \"verify-vmss-scale-a\"}}"
az group deployment create --name verify-vmss-scale-dv2 -g zj-verify-vmss-scale --template-file vmss_template.json --parameters vmss_parameters.json --parameters "{\"vmSku\": {\"value\": \"Standard_D1_v2\"}, \"vmssName\": {\"value\": \"verify-vmss-scale-dv2\"}, \"pipLabel\": {\"value\": \"verify-vmss-scale-dv2\"},\"pipName\": {\"value\": \"verify-vmss-scale-dv2\"}}"
az group deployment create --name verify-vmss-scale-f -g zj-verify-vmss-scale --template-file vmss_template.json --parameters vmss_parameters.json --parameters "{\"vmSku\": {\"value\": \"Standard_F1\"}, \"vmssName\": {\"value\": \"verify-vmss-scale-f\"}, \"pipLabel\": {\"value\": \"verify-vmss-scale-f\"},\"pipName\": {\"value\": \"verify-vmss-scale-f\"}}"
az group deployment create --name verify-vmss-scale-av2 -g zj-verify-vmss-scale --template-file vmss_template.json --parameters vmss_parameters.json --parameters "{\"vmSku\": {\"value\": \"Standard_A1_v2\"}, \"vmssName\": {\"value\": \"verify-vmss-scale-av2\"}, \"pipLabel\": {\"value\": \"verify-vmss-scale-av2\"},\"pipName\": {\"value\": \"verify-vmss-scale-av2\"}}"
az group deployment create --name verify-vmss-scale-d -g zj-verify-vmss-scale --template-file vmss_template.json --parameters vmss_parameters.json --parameters "{\"vmSku\": {\"value\": \"Standard_D1\"}, \"vmssName\": {\"value\": \"verify-vmss-scale-d\"}, \"pipLabel\": {\"value\": \"verify-vmss-scale-d\"},\"pipName\": {\"value\": \"verify-vmss-scale-d\"}}"

# Scale to 1000
az vmss scale --new-capacity 1000 -n verify-vmss-scale-a -g zj-verify-vmss-scale
az vmss scale --new-capacity 1000 -n verify-vmss-scale-dv2 -g zj-verify-vmss-scale
az vmss scale --new-capacity 1000 -n verify-vmss-scale-f -g zj-verify-vmss-scale
az vmss scale --new-capacity 1000 -n verify-vmss-scale-av2 -g zj-verify-vmss-scale
az vmss scale --new-capacity 1000 -n verify-vmss-scale-d -g zj-verify-vmss-scale

# Delete Resource Group for VM Scale Set
az group delete -n zj-verify-vmss-scale -y

###############################################################################

# Create Resource Group for VM
az group create -n zj-verify-vm -l chinanorth

# Create Available Set for VM
az vm availability-set create -n zj-verify-vm-as -g zj-verify-vm -l chinanorth

# SKU A
for i in {1..200}
do
	az vm create -n zj-verify-vm-a-$i -g zj-verify-vm --size Basic_A0 --public-ip-address "" --image Canonical:UbuntuServer:16.04-LTS:latest --availability-set zj-verify-vm-as
done

# SKU Av2
for i in {1..200}
do
	az vm create -n zj-verify-vm-av2-$i -g zj-verify-vm --size Standard_A1_v2 --public-ip-address "" --image Canonical:UbuntuServer:16.04-LTS:latest --availability-set zj-verify-vm-as
done

# SKU D
for i in {1..200}
do
	az vm create -n zj-verify-vm-d-$i -g zj-verify-vm --size Standard_D1 --public-ip-address "" --image Canonical:UbuntuServer:16.04-LTS:latest --availability-set zj-verify-vm-as
done

# SKU Dv2
for i in {1..200}
do
	az vm create -n zj-verify-vm-dv2-$i -g zj-verify-vm --size Standard_D1_v2 --public-ip-address "" --image Canonical:UbuntuServer:16.04-LTS:latest --availability-set zj-verify-vm-as
done

# SKU F
for i in {1..200}
do
	az vm create -n zj-verify-vm-f-$i -g zj-verify-vm --size Standard_F1 --public-ip-address "" --image Canonical:UbuntuServer:16.04-LTS:latest --availability-set zj-verify-vm-as
done

# Delete Resource Group for VM
az group delete -n zj-verify-vm -y

###############################################################################

# Using Azure CLI 1.0

# Create Cloud Service
azure service create --serviceName zj-verify-vm-asm --location chinanorth -s $subscription_id

# Create VM
for i in {1..50}
do
	azure vm create -l chinanorth zj-verify-vm-asm b549f4301d0b4295b8e76ceb65df47d4__Ubuntu-17_04-amd64-server-20170412.1-en-us-30GB -s $subscription_id --userName sysadmin -p "Passw0rd\!0000" -n verify-vm-asm-instance-$i
done

# Delete VM
for i in {1..50}
do
	azure vm delete verify-vm-asm-instance-$i -d zj-verify-vm-asm -y
done

# Create VM for Endpoint
azure vm create -l chinanorth zj-verify-vm-asm b549f4301d0b4295b8e76ceb65df47d4__Ubuntu-17_04-amd64-server-20170412.1-en-us-30GB -s $subscription_id --userName sysadmin -p "Passw0rd\!0000" -n verify-vm-asm-instance-0

for i in {30001..30150}
do
	azure vm endpoint create verify-vm-asm-instance-0 $i $i
done

# Delete Cloud Service
azure service delete zj-verify-vm-asm

