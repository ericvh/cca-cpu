#!/bin/bash
echo Starting FVP...hit ^a-d to exit
docker run -d --rm --privileged --volumes-from `hostname` --name fvp -p 17010:17010 cca-cpu/fvp /workspaces/artifacts/cpud
sleep 1
echo Connect to FVP...
FVP_IP=`docker inspect fvp | jq -r '.[].NetworkSettings.IPAddress'`
/workspaces/artifacts/cpu -key /workspaces/artifacts/identity -namespace "/workspaces:/home" $FVP_IP /workspaces/cca-cpu/bin/start-fvp-cpud-stage2.bash
echo Console terminated, cleaning up...
docker kill fvp
echo Done.