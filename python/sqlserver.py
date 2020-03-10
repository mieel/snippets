## From SQL to DataFrame Pandas
import pandas as pd
import pyodbc
import sqlalchemy

#DataSettings
conn_driver = 'DRIVER={ODBC Driver 13 for SQL Server}'
conn_string = 'SERVER=...;DATABASE=...;UID=...;PWD=...'
quoted = urllib.parse.quote_plus('DRIVER={SQL Server Native Client 11.0};' + conn_string)

#Open Connection
engine = sqlalchemy.create_engine('mssql+pyodbc:///?odbc_connect={}'.format(quoted))

# from csv
target_table = 'TEST'
df = pd.read_csv("./file.csv")
df.to_sql(target_table, schema='dbo', con = engine, if_exists='append', index=False)

# Using an Excel File
target_table = 'TEST2'
df = pd.read_excel('./file.xlsx',
sheet_name=[0,1,2],
index_col=False,
keep_default_na=True,
header=0
)
## Iterate through each items(if multiple sheets)
sheets = df.keys()
for sheet in sheets:
    print(sheet)
    df[sheet].to_sql(target_table, schema='dbo', con = engine, if_exists='append', index=False)

# Validate Results
query = f"SELECT * FROM [dbo].[{target_table}]"
result = engine.execute(query)
result.fetchall()
