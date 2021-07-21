#!/bin/sh

if [ -z "$OCP_NAME" ] || [ -z "$VPC_ID" ] || [ -z "$CLUSTER_VPC_SG_ID" ] || [ -z "$PUBLIC_SUBNET_ID" ]
then
echo "Please ensure the following environment variables are set:
OCP_NAME - The cluster name or customer name needs to be unique
VPC_ID - The vpc id of the Openshift cluster your are wanting to connect to
CLUSTER_VPC_SG_ID - The DEFAULT vpc security group id of the Opendshift cluster you are wanitng to connect to
PUBLIC_SUBNET_ID - The public subnet id of the Openshift cluster you are wanting to connect to"
exit 1
fi

while getopts ":idh" opt; do
  case ${opt} in 
    h ) echo "Usage: 
        [-h] help 
        [-i] install bastion server that can connect to Openshift cluster 
        [-d] delete bastion server"
      ;;
    i ) install="true"
      ;;
    d ) delete="true"
      ;;
    \? ) echo "Usage: cmd [-h] help [-i] install bastion server [-d] delete bastion server" >&2; exit 1
      ;;
    : ) echo "Invalid option: requires [-i] install bastion server or [-d] delete bastion server" >&2; exit 1
     ;;
  esac
done
shift $((OPTIND -1))

if [ -z $install ] && [ -z $delete ]; then
        echo $install
        echo "Invalid option: requires [-i] install or [-d] delete" >&2
        exit 1
fi

SCRIPT_PATH=${0%/*}

export TF_VAR_VPC_ID=${VPC_ID}

export TF_VAR_OCP_NAME="${OCP_NAME}"

export TF_VAR_CLUSTER_VPC_SG_ID=${CLUSTER_VPC_SG_ID}

export TF_VAR_PUBLIC_SUBNET_ID=${PUBLIC_SUBNET_ID}


function install_bastion_server {

    vpcDetails=$(aws ec2 describe-vpcs --vpc-ids)

    echo "Creating key pair ${OCP_NAME}_kp"

    keyCreation=$(aws ec2 create-key-pair --key-name ${OCP_NAME}_kp --query "KeyMaterial" --output text > ${OCP_NAME}_kp.pem)

    echo "${OCP_NAME}_kp.pem created ${SCRIPT_PATH}/${OCP_NAME}_kp.pem"

    chmod 400 ${OCP_NAME}_kp.pem

    export TF_VAR_PUBLIC_KEY=$(ssh-keygen -y -f ${SCRIPT_PATH}/${OCP_NAME}_kp.pem)

    terraform init -input=false && terraform plan -out=tfplan -input=false 

    status=$?
    echo $status

    if [ $status != 0 ]
    then
    echo "Terraform plan failed, please review errors"
    exit 1
    fi

    echo "Creating bastion server and resources"
    terraform apply -input=false tfplan

}

if [ "${install}" == "true" ]; then
        echo 'Installing bastion server and resources'
        install_bastion_server

        
fi


if [ "${delete}" == "true" ]; then
        echo "Deleting key pair ${OCP_NAME}_kp"

        aws ec2 delete-key-pair --key-name ${OCP_NAME}_kp

        echo "Deleting pem file ${SCRIPT_PATH}/${OCP_NAME}_kp.pem"

        rm -rf ${SCRIPT_PATH}/${OCP_NAME}_kp.pem

        terraform destroy -auto-approve
fi