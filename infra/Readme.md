----------------------------- Steps 

* create Kubernetes cluster creation config for kops which has multiple ig, mixed instance group and lifecycle (spot and ondemand)

   Requirement-

        1. setup aws cli
        2. install kubectl
        3. install kops toll
           https://kops.sigs.k8s.io/getting_started/install/#linux
        4. Create aws s3 bucket to store all state file for k8s (this is mandotary)
        5. prepare cluster config/yml file (check kops-cluster.yaml)
           - it have multi instance groupt with spot instances in node group

* steps to install kops cluster 

    - configure aws cli 
    
    - run kops command 
    
            kops create -f kops-cluster.yaml
    
    - once above command run sucessfuly it will create config file in s3 bucket then run update command to actual deployment 
    
           kops update cluster --name poc.k8s.local --yes

    - update kubectl config file
            
           kops export kubecfg --admin
    
    - delete kops cluster

            kops delete cluster poc.k8s.local --yes

 - to get ssh access in instance add you key in cluster using following command 
        
        kops create sshpublickey YOU_CLUSTER_NAME -i ~/.ssh/id_rsa.pub
        
    
      - e.g

            kops create sshpublickey poc.k8s.local -i ~/.ssh/id_rsa.pub
    
      - then run update command
    
            kops update cluster --name poc.k8s.local --yes

 - Create and push docker image to docker repo
    
        cd flask
        sudo docker build -t webapp .
        sudo docker tag webapp:latest kloudgenic/freelancing
        sudo docker login
        sudo docker push kloudgenic/freelancing

 - Helm prepare 
    
    edit value.yml or create new value file for env specific and update values 
    
        cd webapp
        helm template webapp -f value.yml .
        helm upgrade --install webapp -f value.yml .