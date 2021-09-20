# Import in data, do some processing and break up the file
from authentication import ws
from azureml.core import Datastore, Dataset
from azureml.data.datapath import DataPath

# Pipeline step 1: Cleanup file
datastore = Datastore.get(ws, datastore_name='azuremysql')
print (type(datastore))
#query = DataPath(datastore, 'select * from hpi')
#sqldataset = Dataset.Tabular.from_sql_query(
#        query,
#        validate=True,
#        query_timeout=10
#        )
#df = sqldataset.to_pandas_dataframe()
#print(df.head())
#print(f'Length is: {len(df)}')
