#!/bin/bash
grn=$'\e[1;32m'
end=$'\e[0m'

# Start of script
SECONDS=0
printf "${grn}STARTING 'workflow.sh' SCRIPT....${end}\n"
sleep 2

# Create resources
printf "${grn}RUNNING 'create-workspace-sprbac.sh SCRIPT....${end}\n"
./create-workspace-sprbac.sh
sleep 15

# Upload datasets, and register them
printf "${grn}RUNNING '.create-mysql-server.sh' SCRIPT....${end}\n"
./create-mysql-server.sh
sleep 5

# Create compute cluster
printf "${grn}CREATING A CLUSTER....${end}\n"
python clusters.py
sleep 5

# Upload dataset into blob store
printf "${grn}UPLOADING DATA INTO BLOB STORE....${end}\n"
python datasets.py
sleep 5

duration=$SECONDS
printf "${grn} $duration SECONDS ELAPSED. CREATED THE WORKSPACE, LOADED THE DATASET, AND CREATED THE CLUSTER....${end}\n"

