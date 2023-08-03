
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High number of blocked jobs in Jenkins queue.
---

This incident type indicates that there is a high number of blocked jobs in the Jenkins queue. This can cause delays in job execution and can be indicative of a larger issue within the system. It is important to investigate the root cause of the blocked jobs and take appropriate action to prevent this from happening in the future.

### Parameters
```shell
# Environment Variables

export JENKINS_NAMESPACE="PLACEHOLDER"

export JENKINS_POD_NAME="PLACEHOLDER"

export JENKINS_SERVICE_NAME="PLACEHOLDER"

export JENKINS_DEPLOYMENT_NAME="PLACEHOLDER"

export JENKINS_CONTAINER_NAME="PLACEHOLDER"

export DESIRED_NUMBER_OF_EXECUTORS="PLACEHOLDER"

export MINIMUM_DISK_SPACE_GB="PLACEHOLDER"
```

## Debug

### Get the list of pods running in the Jenkins namespace
```shell
kubectl get pods -n ${JENKINS_NAMESPACE}
```

### Check the logs of the Jenkins pod
```shell
kubectl logs ${JENKINS_POD_NAME} -n ${JENKINS_NAMESPACE}
```

### Check the resource usage of the Jenkins pod
```shell
kubectl top pod ${JENKINS_POD_NAME} -n ${JENKINS_NAMESPACE}
```

### Check the status of the Jenkins service
```shell
kubectl get svc ${JENKINS_SERVICE_NAME} -n ${JENKINS_NAMESPACE}
```

### Check the status of the Jenkins deployment
```shell
kubectl get deployment ${JENKINS_DEPLOYMENT_NAME} -n ${JENKINS_NAMESPACE}
```

### Check the Kubernetes events related to the Jenkins deployment
```shell
kubectl get events --sort-by=.metadata.creationTimestamp -n ${JENKINS_NAMESPACE} | grep ${JENKINS_DEPLOYMENT_NAME}
```

### Check the Jenkins queue status
```shell
kubectl exec -it ${JENKINS_POD_NAME} -n ${JENKINS_NAMESPACE} -- sh -c "java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ list-queue-items"
```

### Check the Jenkins build executor status
```shell
kubectl exec -it ${JENKINS_POD_NAME} -n ${JENKINS_NAMESPACE} -- sh -c "java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ list-builds"
```

### Check the Jenkins system logs
```shell
kubectl exec -it ${JENKINS_POD_NAME} -n ${JENKINS_NAMESPACE} -- sh -c "tail -f /var/log/jenkins/jenkins.log"
```

### The Jenkins server may be overloaded with too many queued jobs, causing some of them to be blocked and unable to execute.
```shell


#!/bin/bash



# Set the namespace, pod name, and container name for Jenkins

NAMESPACE=${JENKINS_NAMESPACE}

POD_NAME=${JENKINS_POD_NAME}

CONTAINER_NAME=${JENKINS_CONTAINER_NAME}



# Get the number of queued jobs in Jenkins

QUEUED_JOBS=$(kubectl exec -n $NAMESPACE $POD_NAME -c $CONTAINER_NAME -- jenkins-cli.sh -s http://localhost:8080/ list-queue-items | wc -l)



# Check if the number of queued jobs is above a certain threshold

if [ $QUEUED_JOBS -gt 100 ]; then

  echo "There are $QUEUED_JOBS queued jobs in Jenkins, which is above the threshold of 100. Jenkins may be overloaded."

  # Get the system load average for the past 1 minute

  LOAD_AVG=$(kubectl exec -n $NAMESPACE $POD_NAME -c $CONTAINER_NAME -- uptime | awk -F '[a-z]:' '{ print $2 }' | awk -F ',' '{ print $1 }')

  echo "The system load average for the past 1 minute is $LOAD_AVG."

  # Check if the system load average is above a certain threshold

  if (( $(echo "$LOAD_AVG > 1.0" | bc -l) )); then

    echo "The system load average is above the threshold of 1.0. This may be contributing to the Jenkins overload."

  fi

else

  echo "There are $QUEUED_JOBS queued jobs in Jenkins, which is below the threshold of 100. Jenkins is not overloaded."

fi


```

### There could be an issue with the configuration of the Jenkins server or job settings that is causing certain jobs to block others in the queue.
```shell


#!/bin/bash



# Get the list of pods running in the Jenkins namespace

PODS=$(kubectl get pods -n ${JENKINS_NAMESPACE} -o jsonpath='{.items[*].metadata.name}')



# Loop through all the pods and check their logs for any errors or warnings

for POD in $PODS; do

    echo "Checking logs for pod $POD ..."

    LOGS=$(kubectl logs $POD -n ${JENKINS_NAMESPACE})

    if [[ $LOGS == *"ERROR"* || $LOGS == *"WARNING"* ]]; then

        echo "Found error or warning in logs for pod $POD:"

        echo "$LOGS"

    else

        echo "No errors or warnings found in logs for pod $POD"

    fi

done



# Check the configuration of the Jenkins jobs

JOBS=$(kubectl get jobs -n ${JENKINS_NAMESPACE} -o jsonpath='{.items[*].metadata.name}')

for JOB in $JOBS; do

    echo "Checking configuration for job $JOB ..."

    CONFIG=$(kubectl get job $JOB -n ${JENKINS_NAMESPACE} -o yaml)

    if [[ $CONFIG == *"spec:"* ]]; then

        echo "Configuration for job $JOB looks good:"

        echo "$CONFIG"

    else

        echo "Problem with configuration for job $JOB:"

        echo "$CONFIG"

    fi

done


```

## Repair

### Increase the number of Jenkins executors to alleviate the job backlog and prevent jobs from being blocked in the queue.
```shell


#!/bin/bash



# Set variables

JENKINS_DEPLOYMENT=${JENKINS_DEPLOYMENT_NAME}

NUM_EXECUTORS=${DESIRED_NUMBER_OF_EXECUTORS}



# Scale up Jenkins deployment

kubectl scale deployment ${JENKINS_DEPLOYMENT} --replicas=${NUM_EXECUTORS}


```

### Identify and resolve any issues with the Jenkins infrastructure, such as network or disk space problems, that may be causing the queue to become blocked.
```shell


#!/bin/bash



# Set the namespace where Jenkins is deployed

NAMESPACE="${JENKINS_NAMESPACE}"



# Set the name of the Jenkins deployment

DEPLOYMENT_NAME="${JENKINS_DEPLOYMENT_NAME}"



# Set the minimum disk space threshold in gigabytes

MIN_DISK_SPACE_GB="${MINIMUM_DISK_SPACE_GB}"



# Check the disk space of the Jenkins deployment

disk_space=$(kubectl exec -it -n $NAMESPACE $DEPLOYMENT_NAME df -h | awk '/^\/dev\/sda1/ {print $4}')



# Convert the disk space to gigabytes

disk_space_gb=$(echo $disk_space | sed 's/G//')



# Check if the disk space is below the minimum threshold

if [ $(echo "$disk_space_gb < $MIN_DISK_SPACE_GB" | bc -l) -eq 1 ]; then

    # If the disk space is below the minimum threshold, scale up the Jenkins deployment to a larger size

    kubectl scale deployment -n $NAMESPACE $DEPLOYMENT_NAME --replicas=2

    echo "Jenkins deployment scaled up to 2 replicas to resolve disk space issue."

else

    echo "Jenkins deployment has sufficient disk space."

fi


```