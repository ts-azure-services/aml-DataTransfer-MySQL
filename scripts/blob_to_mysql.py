# Import in data, do some processing and break up the file
import os
from dotenv import load_dotenv
from authentication import ws
from azureml.core import Datastore, Dataset
from azureml.data.datapath import DataPath
from azureml.data.sql_data_reference import SqlDataReference
from azureml.data.data_reference import DataReference
from azureml.pipeline.steps import DataTransferStep
from azureml.core.compute import ComputeTarget, DataFactoryCompute
from azureml.exceptions import ComputeTargetException
from azureml.pipeline.core import Pipeline
from azureml.core import Workspace, Experiment

# Load env variables
env_var=load_dotenv('./mysql_credentials.env')

auth_dict = {
        "server_name":os.environ['SERVER_NAME'],
        "db_name":os.environ['DB_NAME'],
        "user_id":os.environ['USER_ID'],
        "user_pw": os.environ['USER_PW']
        }


# Get default blobstore, and upload CSV file
blob_store = ws.get_default_datastore()

# Create a reference to the source: blob
blob_data_ref = DataReference(
    datastore=blob_store,
    data_reference_name="blob_source",
    path_on_datastore="blob-input-data/HPI_master_cleansed.csv"
    )

# Create a reference to the sink: postgres
#pg_datastore = Datastore.get(ws, datastore_name='pg_data')
mysql_datastore = Datastore.register_azure_my_sql(
        workspace=ws,
        datastore_name="azuremysql",
        server_name=auth_dict['server_name'],
        database_name=auth_dict['db_name'],
        user_id = auth_dict['user_id'],
        user_password = auth_dict['user_pw'],
        #server_name="mysqlserver7799",#.mysql.database.azure.com"
        #database_name="test",
        #user_id="mysqllogin7799@mysqlserver7799",
        #user_password="2A4A8C8B-6539-4EB1-B2AA-CFE03A07F392",
        port_number = '3306',
        endpoint= 'mysql.database.azure.com'
   )

# Query reference
mysql_query_ref = SqlDataReference(
        datastore=mysql_datastore,
        data_reference_name="mysql_query_ref",
        sql_query='select * from hpi'
        )

# Query reference
mysql_table_ref = SqlDataReference(
        datastore=mysql_datastore,
        data_reference_name="mysql_table_ref",
        sql_table='hpi'
        )

# Create the datafactory
data_factory_name = 'adftest1'
def get_or_create_data_factory(workspace, factory_name):
    try:
        return DataFactoryCompute(workspace, factory_name)
    except ComputeTargetException as e:
        if 'ComputeTargetNotFound' in e.message:
            print('Data factory not found, creating...')
            provisioning_config = DataFactoryCompute.provisioning_configuration()
            data_factory = ComputeTarget.create(workspace, factory_name, provisioning_config)
            data_factory.wait_for_completion()
            return data_factory
        else:
            raise e
data_factory_compute = get_or_create_data_factory(ws, data_factory_name)

# Create a data transfer step
blob_to_mysql = DataTransferStep(
    name='blob_to_mysql',
    source_data_reference=blob_data_ref,
    destination_data_reference=mysql_table_ref,
    compute_target=data_factory_compute,
    allow_reuse=False
    )

# Trigger the pipeline
pipeline_01 = Pipeline(steps=[blob_to_mysql],workspace=ws,description="data_transfer_01")
pipeline_run_01 = Experiment(ws,"blob_to_mysql").submit(pipeline_01)
pipeline_run_01.wait_for_completion(show_output=True)
