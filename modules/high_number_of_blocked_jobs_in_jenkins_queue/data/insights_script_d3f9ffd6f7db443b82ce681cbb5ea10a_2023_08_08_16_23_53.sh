

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