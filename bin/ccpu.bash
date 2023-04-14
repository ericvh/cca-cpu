#!/bin/bash

FVP_IP=`docker inspect fvp | jq -r '.[].NetworkSettings.IPAddress'`
cpu -namespace "/workspaces:/lib:/lib64:/usr:/bin:/etc:/home" $FVP_IP $@