# Intent 
- Showcase the code to transfer data from a blob store to an Azure MySQL Database
- Sample dataset taken from [Federal Housing Finance Agency datasets](https://www.fhfa.gov/DataTools/Downloads/Pages/House-Price-Index-Datasets.aspx#mpo)

## File Structure
- LICENSE.TXT
- README.md
- requirements.txt
- input-data
	- HPI_master_cleansed.csv ```input data```
- scripts
	- "Setup scripts"
		- workflow.sh ```shell script to initiate complete end-to-end workflow```
		- create-workspace-sprbac.sh ```shell script embedded in 'workflow.sh' to create workspace/infra```
		- create-mysql-server.sh ```shell script embedded in 'workflow.sh' to create MySQL database```
		- datasets.py ```uploads the raw data into blobstore; part of 'workflow.sh' process```
		- clusters.py ```creates a cluster; part of 'workflow.sh' process```
	- "Main scripts"
		- blob_to_mysql.py ```python script to initiate DataTransfer step from blob store to MySQL```
		- db_script.sql ```Sample commands to manually run in MySQL to create the table schema```
		- test_datastore_load.py ```WIP; to test the registration of the MySQL database```
	- "Authentication & Environment variables"
		- authentication.py ```Used to authenticate the workspace with a service principal```
		- sub.env ```subscription info: needs to be in place prior to execution```
		- variables.env ```gets created during workflow```
		- infra.env ```gets created during workflow; contains resource group and location```
		- mysql_credentials.env ```gets created during workflow; contains MySQL login credentials```
		- config.json ```gets created during workflow```
	- "Random name generator"
		- adjectives.txt ```used as input into random_name.py```
		- nouns.txt ```used as input into random_name.py```
		- random_name.py ```uses adjectives.txt. and nouns.txt to create a random name```

### Additional Notes
- For this example, the network access in the 'Connection Security' blade for MySQL should be the following:
	- Deny public network access: NO
	- Allow access to Azure services: YES
	- AllowClientIP Firewall Rule (for your own client)
- Before running the 'blob_to_mysql' script, you have to ensure that there is an empty table created in the
  target database, i.e. 'defaultdb' in the Azure MySQL database. Run the commands in the sql script to use
  this database, and create a table schema to capture the blob schema.
- Of note, it does not appear that registration of a MySQL database as a datastore is permitted.
- For Azure SQL Database, you must use service principal authentication: [Reference](https://docs.microsoft.com/en-us/azure/data-factory/connector-azure-sql-database?tabs=data-factory#service-principal-authentication)
