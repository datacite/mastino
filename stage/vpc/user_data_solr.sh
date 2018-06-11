#!/bin/bash

service docker start

# set ECS agent options
{
  echo "ECS_CLUSTER=${cluster_name}"
  echo "NO_PROXY=169.254.169.254,169.254.170.2,/var/run/docker.sock"
} >> /etc/ecs/ecs.config

start ecs

# start datadog container
docker run -d --name "dd-agent" \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  --volume /proc/:/host/proc/:ro \
  --volume /cgroup/:/host/sys/fs/cgroup:ro \
  --env DD_API_KEY="${dd_api_key}" \
  --restart always \
  datadog/agent:latest

# start solr docker container
docker run -d -p "${solr_port}":80 --name solr \
  --hostname "${hostname}" \
  --env MYSQL_HOST="${mysql_host}" \
  --env MYSQL_DATABASE="${mysql_database}" \
  --env MYSQL_USER="${mysql_user}" \
  --env MYSQL_PASSWORD="${mysql_password}" \
  --env SOLR_HOME="${solr_home}" \
  --env SOLR_URL="${solr_url}" \
  --env SOLR_USER="${solr_user}" \
  --env SOLR_PASSWORD="${solr_password}" \
  --env SOLR_VERSION="${solr_version}" \
  --env TEST_PREFIX="${test_prefix}" \
  --env LOG_LEVEL=INFO \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /opt/solr:/data/solr/collection1 \
  --volume /opt/.m2:/root/.m2 \
  --restart always \
  datacite/search:"${solr_tag}"


# start solr indexing
curl -u "${solr_user}":"${solr_password}" http://127.0.0.1:"${solr_port}"/admin/dataimport?command=full-import&commit=true&clean=true&optimize=false&wt=json
