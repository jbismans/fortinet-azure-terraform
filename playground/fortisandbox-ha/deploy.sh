#!/bin/bash
echo "
##############################################################################################################
#
# Fortinet FortiGate Terraform deployment template
# FortiGate SD-WAN deployment
#
##############################################################################################################

"

# Stop running when command returns error
set -e

##############################################################################################################
# Azure Service Principal
##############################################################################################################
# AZURE_CLIENT_ID=''
# AZURE_CLIENT_SECRET=''
# AZURE_SUBSCRIPTION_ID=''
# AZURE_TENANT_ID=''
##############################################################################################################

##############################################################################################################
# LICENSE FILE HANDLING
##############################################################################################################
# LICENSE FILE Location
#
# export var="../folder/file"
# Examples
# export TF_VAR_FGT_LICENSE_FILE_A="../licenses/FGVM04xxx.lic"
# export TF_VAR_FGT_LICENSE_FILE_A="../licenses/FGVM04yyy.lic"
#
##############################################################################################################

PLAN="terraform.tfplan"

if [ -z "$DEPLOY_LOCATION" ]
then
    # Input location
    echo -n "Enter location (e.g. westeurope): "
    stty_orig=`stty -g` # save original terminal setting.
    read location         # read the location
    stty $stty_orig     # restore terminal setting.
    if [ -z "$location" ]
    then
        location="westeurope"
    fi
else
    location="$DEPLOY_LOCATION"
fi
export TF_VAR_LOCATION="$location"
echo ""
echo "--> Deployment in $location location ..."
echo ""

if [ -z "$DEPLOY_PREFIX" ]
then
    # Input prefix
    echo -n "Enter prefix: "
    stty_orig=`stty -g` # save original terminal setting.
    read prefix         # read the prefix
    stty $stty_orig     # restore terminal setting.
    if [ -z "$prefix" ]
    then
        prefix="forti"
    fi
else
    prefix="$DEPLOY_PREFIX"
fi
export TF_VAR_PREFIX="$prefix"
echo ""
echo "--> Using prefix $prefix for all resources ..."
echo ""
rg_cgf="$prefix-RG"

if [ -z "$DEPLOY_PASSWORD" ]
then
    # Input password
    echo -n "Enter password: "
    stty_orig=`stty -g` # save original terminal setting.
    stty -echo          # turn-off echoing.
    read passwd         # read the password
    stty $stty_orig     # restore terminal setting.
    echo ""
else
    passwd="$DEPLOY_PASSWORD"
    echo ""
    echo "--> Using password found in env variable DEPLOY_PASSWORD ..."
    echo ""
fi
PASSWORD="$passwd"

if [ -z "$DEPLOY_USERNAME" ]
then
    USERNAME="azureuser"
else
    USERNAME="$DEPLOY_USERNAME"
fi
echo ""
echo "--> Using username '$USERNAME' ..."
echo ""

SUMMARY="summary.out"

echo ""
echo "==> Starting Terraform deployment"
echo ""
cd terraform/

echo ""
echo "==> Terraform init"
echo ""
terraform init

echo ""
echo "==> Terraform plan"
echo ""
terraform plan --out "$PLAN" \
                -var "USERNAME=$USERNAME" \
                -var "PASSWORD=$PASSWORD"

echo ""
echo "==> Terraform apply"
echo ""
terraform apply "$PLAN"
if [[ $? != 0 ]];
then
    echo "--> ERROR: Deployment failed ..."
    exit $rc;
fi

echo ""
echo "==> Terraform output deployment summary"
echo ""
terraform output deployment_summary > "../output/$SUMMARY"

cd ../
echo "
##############################################################################################################
#
# FSA HA
#
##############################################################################################################

 Deployment information:

Username: $USERNAME
"
cat "output/$SUMMARY"
echo "

##############################################################################################################"
