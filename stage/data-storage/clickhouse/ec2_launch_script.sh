#!/bin/bash

sudo docker plugin install rexray/ebs:latest REXRAY_PREEMPT=true EBS_REGION=eu-west-1 --grant-all-permissions


# Adding cluster name in ecs config
echo ECS_CLUSTER=stage >> /etc/ecs/ecs.config
cat /etc/ecs/ecs.config | grep "ECS_CLUSTER"

echo ""
echo "CLICKHOUSE-STAGE LAUNCHED"
echo ""
