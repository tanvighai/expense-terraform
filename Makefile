dev:
	#rm -rf .terraform
	terraform init -backend-config=env-dev/state.tfvars
	terraform apply -auto-approve -var-file=env-dev/inputs.tfvars


prod:
	rm -rf .terraform
	terraform init -backend-config=env-prod/state.tfvars
	terraform apply -auto-approve -var-file=env-prod/inputs.tfvars


dev-destroy:
	#rm -rf .terraform
	terraform init -backend-config=env-dev/state.tfvars
	terraform destroy -auto-approve -var-file=env-dev/inputs.tfvars


prod-destroy:
	rm -rf .terraform
	terraform init -backend-config=env-prod/state.tfvars
	terraform destroy -auto-approve -var-file=env-prod/inputs.tfvars









#Create a VPC
#Create 4 Subnets (2private and 2 public in AZ1 and AZ2)
#Create one internet Gateway and attach it to VPC
#Create one elastic IP
#Create one NAT gateway
#Create two route tables (1public & 1private)
#Add IGW to public and NAT GW to private route table
#Attach public route table to public subnets and private route table to private subnets
#Create peering connections to public route table , private route table and default route table.
