

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