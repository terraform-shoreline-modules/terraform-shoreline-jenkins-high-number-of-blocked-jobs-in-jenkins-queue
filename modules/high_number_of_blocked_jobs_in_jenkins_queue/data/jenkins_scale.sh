

#!/bin/bash



# Set variables

JENKINS_DEPLOYMENT=${JENKINS_DEPLOYMENT_NAME}

NUM_EXECUTORS=${DESIRED_NUMBER_OF_EXECUTORS}



# Scale up Jenkins deployment

kubectl scale deployment ${JENKINS_DEPLOYMENT} --replicas=${NUM_EXECUTORS}