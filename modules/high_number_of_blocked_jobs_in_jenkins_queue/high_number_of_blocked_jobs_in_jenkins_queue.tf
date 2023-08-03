resource "shoreline_notebook" "high_number_of_blocked_jobs_in_jenkins_queue" {
  name       = "high_number_of_blocked_jobs_in_jenkins_queue"
  data       = file("${path.module}/data/high_number_of_blocked_jobs_in_jenkins_queue.json")
  depends_on = [shoreline_action.invoke_insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53,shoreline_action.invoke_pods_and_jobs_check,shoreline_action.invoke_jenkins_scale,shoreline_action.invoke_jenkins_disk_checker]
}

resource "shoreline_file" "insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53" {
  name             = "insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53"
  input_file       = "${path.module}/data/insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53.sh"
  md5              = filemd5("${path.module}/data/insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53.sh")
  description      = "The Jenkins server may be overloaded with too many queued jobs, causing some of them to be blocked and unable to execute."
  destination_path = "/agent/scripts/insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "pods_and_jobs_check" {
  name             = "pods_and_jobs_check"
  input_file       = "${path.module}/data/pods_and_jobs_check.sh"
  md5              = filemd5("${path.module}/data/pods_and_jobs_check.sh")
  description      = "There could be an issue with the configuration of the Jenkins server or job settings that is causing certain jobs to block others in the queue."
  destination_path = "/agent/scripts/pods_and_jobs_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "jenkins_scale" {
  name             = "jenkins_scale"
  input_file       = "${path.module}/data/jenkins_scale.sh"
  md5              = filemd5("${path.module}/data/jenkins_scale.sh")
  description      = "Increase the number of Jenkins executors to alleviate the job backlog and prevent jobs from being blocked in the queue."
  destination_path = "/agent/scripts/jenkins_scale.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "jenkins_disk_checker" {
  name             = "jenkins_disk_checker"
  input_file       = "${path.module}/data/jenkins_disk_checker.sh"
  md5              = filemd5("${path.module}/data/jenkins_disk_checker.sh")
  description      = "Identify and resolve any issues with the Jenkins infrastructure, such as network or disk space problems, that may be causing the queue to become blocked."
  destination_path = "/agent/scripts/jenkins_disk_checker.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53" {
  name        = "invoke_insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53"
  description = "The Jenkins server may be overloaded with too many queued jobs, causing some of them to be blocked and unable to execute."
  command     = "`chmod +x /agent/scripts/insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53.sh && /agent/scripts/insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53.sh`"
  params      = ["JENKINS_NAMESPACE","JENKINS_POD_NAME","JENKINS_CONTAINER_NAME","NAMESPACE"]
  file_deps   = ["insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53"]
  enabled     = true
  depends_on  = [shoreline_file.insights_script_d3f9ffd6f7db443b82ce681cbb5ea10a_2023_08_08_16_23_53]
}

resource "shoreline_action" "invoke_pods_and_jobs_check" {
  name        = "invoke_pods_and_jobs_check"
  description = "There could be an issue with the configuration of the Jenkins server or job settings that is causing certain jobs to block others in the queue."
  command     = "`chmod +x /agent/scripts/pods_and_jobs_check.sh && /agent/scripts/pods_and_jobs_check.sh`"
  params      = ["JENKINS_NAMESPACE"]
  file_deps   = ["pods_and_jobs_check"]
  enabled     = true
  depends_on  = [shoreline_file.pods_and_jobs_check]
}

resource "shoreline_action" "invoke_jenkins_scale" {
  name        = "invoke_jenkins_scale"
  description = "Increase the number of Jenkins executors to alleviate the job backlog and prevent jobs from being blocked in the queue."
  command     = "`chmod +x /agent/scripts/jenkins_scale.sh && /agent/scripts/jenkins_scale.sh`"
  params      = ["JENKINS_DEPLOYMENT_NAME","DESIRED_NUMBER_OF_EXECUTORS"]
  file_deps   = ["jenkins_scale"]
  enabled     = true
  depends_on  = [shoreline_file.jenkins_scale]
}

resource "shoreline_action" "invoke_jenkins_disk_checker" {
  name        = "invoke_jenkins_disk_checker"
  description = "Identify and resolve any issues with the Jenkins infrastructure, such as network or disk space problems, that may be causing the queue to become blocked."
  command     = "`chmod +x /agent/scripts/jenkins_disk_checker.sh && /agent/scripts/jenkins_disk_checker.sh`"
  params      = ["JENKINS_DEPLOYMENT_NAME","JENKINS_NAMESPACE","MINIMUM_DISK_SPACE_GB","NAMESPACE"]
  file_deps   = ["jenkins_disk_checker"]
  enabled     = true
  depends_on  = [shoreline_file.jenkins_disk_checker]
}

