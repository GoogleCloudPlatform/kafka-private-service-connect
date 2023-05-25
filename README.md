# K8S host project/cluster; share Kafka topics to service project/clusters with Private Service Connect
TL;DR Want to Expose Kafka topics in a host K8S cluster/project to K8S clusters in separate consumer projects securely and with minimal configuration?

## What we are trying to do?

There are many times, when building an environment, that it's necessary to have compartmentalised 'silos' of applications and data. This might be because the service you're providing involves separating customer data, isolation for billing purposes or maybe it's a regluatory requirement. In Google Cloud there are many ways to achieve this setup, some more scalable/supportable than others. 


The most basic way is to setup [VPC peering](https://cloud.google.com/vpc/docs/vpc-peering)/forwarding between all the projects. This enables subnets in the host project to be shared with the service project and vice versa. The downside is you can't have overlapping IP subnets and all projects' VPCs need to be configured individually on creation and each time there's a change. There are also some limnits on the number of peers you can have. 

The second option is shared VPC [Shared VPC](https://cloud.google.com/vpc/docs/shared-vpc) which enables service projects to gain access to IP subnest that exist in the host project. Only the host project needs the firewall rules/policy to be setup. More secure, much more easy. But there are limitations with this too.

The most modern, and by far the most flexible way is with [Private Service Connect](https://cloud.google.com/vpc/docs/private-service-connect) which enable cross project, corss-region and even cross organisation(!) sharing of your applications. 

This article specifically addresses how to operate a [Kafka](https://kafka.apache.org/) Cluster in [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview) and have service projects access the Kafka topics securely and with the lowest configuration requirements.

To enable this we will use : 
* [GKE](https://cloud.google.com/kubernetes-engine)
* [Strimzi](https://strimzi.io/) A Kubernetes [operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) to manage the Kafka deployment in GKE
* [Internal Load Balancer](https://cloud.google.com/kubernetes-engine/docs/how-to/internal-load-balancing) to expose Bootstrap and Broker Kafka listener
* [Private Service Connect](https://cloud.google.com/vpc/docs/private-service-connect) to expose Kafka securely outside of the VPC network without VPC peering or shared VPC
* [Terraform](https://www.terraform.io/) to deploy the assets

We will configure Private Service Connect (PSC) to connect two projects. (1) The Kafka project which will expose the Endpoint to PSC, and (2) a consumer (service) project which will consume the Endpoint via PSC.

## Kafka Project Setup

In the Kafka project (the project which will host the Kafka cluster):

Make a copy of the [terraform.tfvarssample](./terraform.tfvarssample) file  in a terrafrom.tfvars file. Replace the values with yours then execute :

```bash
terraform init
terraform apply
```
Have a look at the created resources and accept. You'll need to wait 10 to 15 minutes whlie the infrastructure is created.

### Deploy Kafka with Strimzi Operator

Now we will install the Strimzi Operator and deploy our Kafka cluster:

```bash
#Get GKE credential
gcloud container clusters get-credentials <GKE CLUSTER NAME> --region <REGION> --project <PROJECT ID>
kubectl create namespace kafka
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
```

Then, create our first Kafka Cluster:

```bash
#Get GKE credential
kubectl apply -f strimzi/kafka.yaml -n kafka
```

Once the Kafka cluster is created, the Bootstrap Server and the Broker are exposed with a Cluster-IP. Next we will expose these 2 listeners through an Internal Load Balancer:

```bash
#Get GKE credential
kubectl apply -f strimzi/kafka-ilb.yaml -n kafka
```

## Publish Private Service Connect Endpoints:

Now your Kafka cluster is ready to publish the Boostrap and Broker-0 listeners. You can simply execute this code to publish the endpoint: 

```bash
ILBBOOT=$(kubectl get svc simple-kafka-cluster-kafka-plain-bootstrap -n kafka -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
ILBBROKER=$(kubectl get svc simple-kafka-cluster-kafka-plain-0 -n kafka -o jsonpath="{.status.loadBalancer.ingress[0].ip}") 
#retreive forwarding rule for bootstrap and broker svc
FORWARD_BOOT=$(gcloud compute forwarding-rules list --filter=IP_ADDRESS:$ILBBOOT --format="value(selfLink.basename())")
FORWARD_BROKER=$(gcloud compute forwarding-rules list --filter=IP_ADDRESS:$ILBBROKER --format="value(selfLink.basename())")

terraform apply -var psc-creation=true -var bootstrap-rule=$FORWARD_BOOT -var broker-rule=$FORWARD_BROKER
```

Now, in the GCP console, locate the Private Service Connect UI where you should see 2 published endpoints.

# Consume a Private Service Connect service:

Next, in the consumer project, we will configure Private Service Connect to use our 2 published endpoints.

At the same time we will :
* Create a [Serverless VPC Connector](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access)
* Deploy a [Kafka Client App](https://github.com/provectus/kafka-ui) in [Cloud Run](https://cloud.google.com/run)
* Register a Cloud DNS entry for the Bootstrap and Broker server ( important for the broker, we will use the advertised dns name)
* Connect the Kafka client to our Kafka cluster through Private Service Connect

```bash
terraform apply -var psc-creation=true -var bootstrap-rule=$FORWARD_BOOT -var broker-rule=$FORWARD_BROKER -var consumer-creation=true
```
Finally, if you go to Cloud Run service deploy, register a cluster and give as a Bootstrap Server the value :

| Bootstrap Server               | Port |
|--------------------------------|------|
| kafka-boootstrap.kafka.demo.io | 9092 |

You should now have access to your Kafka cluster, from a Cloud Run instance, through Private Service Connect.
