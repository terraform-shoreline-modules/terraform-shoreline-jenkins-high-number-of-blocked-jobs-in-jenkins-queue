

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