# Expose Kafka with Private Service Connect

## What we are trying to do ?

We are a company, with our own Google Cloud Organisation and we operate a [Kafka](https://kafka.apache.org/) Cluster in [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview).


We will use : 
* GKE
* [Strimzi](https://strimzi.io/) operator to manage the Kafka deployment in GKE
* [Internal Load Balancer](https://cloud.google.com/kubernetes-engine/docs/how-to/internal-load-balancing) to expose Bootstrap and Broker Kafka listener
* [Private Service Connect](https://cloud.google.com/vpc/docs/private-service-connect) to expose Kafka securely outside of the VPC network without VPC peering or shared VPC
* [Terraform](https://www.terraform.io/) to deploy the assets

We will configure Private Service Connect (PSC) in two project. The Kafka project which expose the Endpoint to PSC, and a consumer project which consume the Endpoint threw PSC.

## Kafka Project

In the Kafka project (the project which host the Kafka cluster).

Make a copy of [terraform.tfvarssample](./kafka-project/terraform.tfvarssample) file  in a terrafrom.tfvars file. Replace the values with yours.

```bash
cd kafka-project
terraform init
terraform apply
```
Have a look on the created resources and accept. Wait 10 to 15 minutes the infrastructure is created

### Deploy Kafka with Strimzi Operator

Now we will install the Strimzi Operator and deploy our Kafka cluster

```bash
#Get GKE credential
gcloud container clusters get-credentials <GKE CLUSTER NAME> --region <REGION> --project <PROJECT ID>
kubectl create namespace kafka
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
```

Then create our first Kafka Cluster

```bash
#Get GKE credential
kubectl apply -f strimzi/kafka.yaml -n kafka
```

The Kafka cluster is now created, but the Bootstrap Server and the Broker are exposed with a Cluster-IP. Now we will expose these 2 listeners with an Internal Load Balancer.
```bash
#Get GKE credential
kubectl apply -f strimzi/kafka-ilb.yaml -n kafka
```

## Publish Private Service Connect Endpoints

Now your Kafka cluster is ready to publish their Boostrap and Broker-0 listeners.

You can simply execute this to publish the endpoint : 

```bash
ILBBOOT=$(kubectl get svc simple-kafka-cluster-kafka-plain-bootstrap -n kafka -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
ILBBROKER=$(kubectl get svc simple-kafka-cluster-kafka-plain-0 -n kafka -o jsonpath="{.status.loadBalancer.ingress[0].ip}") 
#retreive forwarding rule for bootstrap and broker svc
FORWARD_BOOT=$(gcloud compute forwarding-rules list --filter=IP_ADDRESS:$ILBBOOT --format="value(selfLink.basename())")
FORWARD_BROKER=$(gcloud compute forwarding-rules list --filter=IP_ADDRESS:$ILBBROKER --format="value(selfLink.basename())")

terraform apply -var psc-creation=true -var bootstrap-rule=$FORWARD_BOOT -var broker-rule=$FORWARD_BROKER
```

Now, if you go to the Private Service Connect UI, you can see 2 published endpoints.


# Consume a Private Service Connect service

Now in the consumer project, we will configure Private Service Connect to use our 2 published endpoints.

In the same time we will :
* Create a [Serverless VPC Connector](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access)
* Deploy a [Kafka Client App](https://github.com/provectus/kafka-ui) in [Cloud Run](https://cloud.google.com/run)
* Register a Cloud DNS entry for the Bootstrap and Broker server ( important for the broker, we will use the advertised dns name)
* Connect the Kafka client to our Kafka cluster threw Private Service Connect



```bash
terraform apply -var psc-creation=true -var bootstrap-rule=$FORWARD_BOOT -var broker-rule=$FORWARD_BROKER -var consumer-creation=true
```

Now, if you go to the Cloud Run service deploy, register a cluster and give as a Bootstrap Server the value :

| Bootstrap Server               | Port |
|--------------------------------|------|
| kafka-boootstrap.kafka.demo.io | 9092 |

You get now access to your Kafka cluster, from a Cloud Run instance, threw Private Service Connect
