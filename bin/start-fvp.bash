#!/bin/bash
echo Starting FVP...hit ^a-d to exit
docker run -i -t --rm --privileged --volumes-from `hostname` --name fvp -p 17010:17010 cca-cpu/fvp /workspaces/cca-cpu/bin/start-fvp-stage2.bash

#echo Waiting for service to startup...
#sleep 1
#echo Startup FVP
#cpu -namespace "/workspaces:/home" 172.17.0.3 /workspaces/cca-cpu/bin/start-fvp-original.bash
#echo Connecting to Linux console
#PWD=/ cpu -namespace "" 172.17.0.3 screen -r Linux
#echo killing FVP...
#docker kill fvp
