Use this commands to run the deploy the infrastructure

For the first region
1. terraform init or terraform init -reconfigure
2. terraform workspace new weu
3. terraform plan -var-file="weuterraform.tfvars"
4. terraform apply -var-file="weuterraform.tfvars" -auto-approve

For the second region
1. terraform init or terraform init -reconfigure
2. terraform workspace new eus
3. terraform plan -var-file="eusterraform.tfvars"
4. terraform apply -var-file="eusterraform.tfvars" -auto-approve

Note: WEU means West Europe and EUS means East Europe

Change the regions to suit your requirement wherever you find them either prepended to a resource name/file name or as value for location