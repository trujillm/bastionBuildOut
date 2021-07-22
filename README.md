# bastion-server-build

## Overview
Creates a bastion server that can connect to a private Openshift cluster.

## Pre requisite Requirements
**Install requirements**

1. Terraform --> [Install terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)
2. AWS command line --> [Install AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
3. Configure AWS account for cli --> [Configure AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config)

## Running

**Required environment variables:**
1. OCP_NAME - Unique name to identify server, should match the cluster name or customer name
2. VPC_ID - The vpc id of the Openshift cluster your are wanting to connect to
3. CLUSTER_VPC_SG_ID - The DEFAULT vpc security group id of the Opendshift cluster you are wanitng to connect to
4. PUBLIC_SUBNET_ID - The public subnet id of the Openshift cluster you are wanting to connect to

**Usage:**
- [-h] help 
- [-i] Install bastion server that can connect to Openshift cluster 
- [-d] Delete bastion server
- -i to install or -d delete are required to run

**Example run install**

./setupBastion.sh -i 
