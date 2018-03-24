#!/bin/bash

# install librato collectd
curl -s https://metrics-api.librato.com/agent_installer/0abf57a25e2294c3 | sudo bash

service docker start

# set ECS agent options
{
  echo "ECS_CLUSTER=${cluster_name}"
  echo "NO_PROXY=169.254.169.254,169.254.170.2,/var/run/docker.sock"
} >> /etc/ecs/ecs.config

start ecs

# start logspout service container
docker run -d --name="logspout" \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  --restart always \
  gliderlabs/logspout \
  syslog://"${syslog_host}":"${syslog_port}"

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
  --env LOG_LEVEL=INFO \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /opt/solr:/data/solr/collection1 \
  --volume /opt/.m2:/root/.m2 \
  --restart always \
  datacite/search:"${solr_tag}"

# start solr indexing
curl -u "${solr_user}":"${solr_password}" http://127.0.0.1:"${solr_port}"/admin/dataimport?command=full-import&commit=true&clean=true&optimize=false&wt=json
