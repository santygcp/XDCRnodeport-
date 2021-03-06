#!/bin/sh
#Variables

LICENSE_FILE="license.xml"
VALUES1="cluster1-values.yaml"
VALUES2="cluster2-values.yaml"


helm repo add santy https://voltdb-kubernetes-charts.storage.googleapis.com

#creating a cluster

gcloud container clusters create  --machine-type "c2-standard-8" --image-type UBUNTU_CONTAINERD  --num-nodes 3    xdcr-1 --disk-type "pd-ssd" --disk-size "300" --zone "europe-west1-b" 


#connecting to the cluster

kubectl config use-context gke_fourth-epigram-293718_europe-west1-b_xdcr-1


#create the secret registry

kubectl create secret docker-registry dockerio-registry --docker-username=jadejakajal13  --docker-password=b461d1b4-82c4-499e-afc0-f17943a16411  --docker-email=jadejakajal13@gmail.com

helm install xdcr1 --version=1.3.5 --values $VALUES1 --set operator.image.tag=1.3.5 --set-file cluster.config.licenseXMLFile=$LICENSE_FILE santy/voltdb

sleep 240

kubectl create -f votertest.yaml

sleep 180

kubectl cp run.sh votertestfinal:/opt/voltdb/voter/run.sh/
kubectl cp ddl.sql votertestfinal:/opt/voltdb/voter/ddl.sql/
#kubectl exec -it votertestfinal -- /bin/bash -c "cd /opt/voltdb/voter/ ; ./run.sh init"
#kubectl exec -it votertestfinal -- /bin/bash -c "cd /opt/voltdb/voter/ ; ./run.sh client"


kubectl exec -it votertestfinal -- /bin/bash -c "cd /opt/voltdb/voter/ ; ./run.sh init xdcr1-voltdb-cluster-client.default.svc.cluster.local"
kubectl exec -it votertestfinal -- /bin/bash -c "cd /opt/voltdb/voter/ ; ./run.sh client xdcr1-voltdb-cluster-client.default.svc.cluster.local"

#retVal=$?
#if [ $retVal -ne 0 ]; then
#    echo "all job's completed"
#fi

gcloud container clusters create  --machine-type "c2-standard-8" --image-type UBUNTU_CONTAINERD  --num-nodes 3    xdcr-2 --disk-type "pd-ssd" --disk-size "300" --zone "europe-west1-b"

kubectl config use-context gke_fourth-epigram-293718_europe-west1-b_xdcr-2

kubectl create secret docker-registry dockerio-registry --docker-username=jadejakajal13  --docker-password=b461d1b4-82c4-499e-afc0-f17943a16411  --docker-email=jadejakajal13@gmail.com

helm install xdcr2 --version=1.3.5 --values $VALUES2 --set operator.image.tag=1.3.5 --set-file cluster.config.licenseXMLFile=$LICENSE_FILE santy/voltdb

sleep 240

kubectl create -f votertest2.yaml

sleep 180

kubectl cp run.sh votertestfinal2:/opt/voltdb/voter/run.sh/

kubectl cp ddl.sql votertestfinal2:/opt/voltdb/voter/ddl.sql/

kubectl exec -it votertestfinal2 -- /bin/bash -c "cd /opt/voltdb/voter/ ; ./run.sh init xdcr2-voltdb-cluster-client.default.svc.cluster.local"

A=`kubectl get nodes -o wide | tail -1 | awk -F " " {'print $7'}`
B=`kubectl get svc | grep -- -dr | tail -1 | awk -F " " {'print $5'} | cut -c 6-10`
VAR2=$A:$B
helm --kube-context=gke_fourth-epigram-293718_europe-west1-b_xdcr-1 upgrade xdcr1 santy/voltdb --reuse-values --version=1.3.5 --set cluster.config.deployment.dr.connection.source="$VAR2"

kubectl config use-context gke_fourth-epigram-293718_europe-west1-b_xdcr-1

A=`kubectl get nodes -o wide | tail -1 | awk -F " " {'print $7'}`
B=`kubectl get svc | grep -- -dr | tail -1 | awk -F " " {'print $5'} | cut -c 6-10`
VAR1=$A:$B

helm --kube-context=gke_fourth-epigram-293718_europe-west1-b_xdcr-2 upgrade xdcr2 santy/voltdb --reuse-values --version=1.3.5 --set cluster.config.deployment.dr.connection.source="$VAR1"

echo " check the connectivity using the below UI"
kubectl get nodes -o wide | tail -1 | awk -F " " {'print $7'}






















