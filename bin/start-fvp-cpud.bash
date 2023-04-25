#!/bin/bash
echo Starting FVP...hit ^a-d to exit
docker run -i -t --rm --privileged --volumes-from `hostname` --name fvp -p 17010:17010 cca-cpu/fvp /workspaces/artifacts/cpud

