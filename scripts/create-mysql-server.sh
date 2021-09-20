#!/bin/bash
#Script to provision a new Azure ML workspace
grn=$'\e[1;32m'
end=$'\e[0m'

# Start of script
SECONDS=0

# Source variables to activate in right subscription
source sub.env
sub_id=$SUB_ID
az account set -s $sub_id

source infra.env
resourcegroup=$RG
location=$LOCATION

# Setup variables
number=$[ ( $RANDOM % 10000 ) + 1 ]
demoserver='mysqlserver'$number
myadmin='mysqllogin'$number
myadminpw=$(uuidgen)

# Create MySQL flexible server
printf "${grn}STARTING CREATION OF MYSQL SERVER...${end}\n"
server_create=$(az mysql server create \
--resource-group $resourcegroup \
--name $demoserver \
--location $location \
--admin-user $myadmin \
--admin-password $myadminpw \
--public Enabled)
printf "Result of server creation process:\n $server_create \n"

IP=$(curl -s ipinfo.io/ip)
echo "External IP address from ipinfo.io: $IP \n"

# Configure a server-level firewall rule for ClientIP
echo "Configuring a server-level firewall rule for $demoserver based on IP:$IP"
firewall_rule_create=$(az mysql server firewall-rule create \
--server-name $demoserver \
--resource-group $resourcegroup \
--name "AllowClientIP" \
--start-ip-address $IP \
--end-ip-address $IP)
printf "Firewall rule output:\n $firewall_rule_create \n"


# Capture credentials for 'jq' parsing
sleep 5
credFile='mysql_cred.json'
printf "$server_create" > $credFile
serverNAME=$(cat $credFile | jq -r '.name')
databaseNAME=$(cat $credFile | jq -r '.databaseName')
administratorLOGIN=$(cat $credFile | jq -r '.administratorLogin')
userPASSWORD=$(cat $credFile | jq -r '.password')
rm $credFile

# Create MySQL credentials file
printf "${grn}WRITING OUT MYSQL CREDENTIALS......${end}\n"
env_variable_file='mysql_credentials.env'
printf "SERVER_NAME=$serverNAME \n" > $env_variable_file
printf "DB_NAME=$databaseNAME \n" >> $env_variable_file
printf "USER_ID=$administratorLOGIN@$serverNAME \n" >> $env_variable_file
printf "USER_PW=$userPASSWORD \n" >> $env_variable_file
