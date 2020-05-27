import os
import sqlalchemy
import argparse
import pandas as pd
import sqlite3
import datetime

# OS endereços de nosso projeto e sub pastas
# os.path = modulo que da ferramentas para trabalhar nos camiinhos do meu sistema operacional.
# Exemplo: me passa o caminho de onde o meu Python está executando
BASE_DIR = os.path.dirname( os.path.dirname( os.path.dirname( os.path.abspath(__file__) ) ) )
DATA_DIR = os.path.join( BASE_DIR, 'data')
SQL_DIR = os.path.join(BASE_DIR, 'src', 'sql')

# Parser de data para fazer a foto
#Incluindo a data e o Args Parse
parser = argparse.ArgumentParser()
parser.add_argument('--date_end', '-e', help='Data de fim da extração', default='2018-06-01')
args = parser.parse_args()

date_end = args.date_end
ano = int(date_end.split("-")[0])-1
mes = int(date_end.split("-")[1])
date_init = f"{ano}-{mes}-01"

#Abrindo o arquivo e importando (importar a query)
with open(os.path.join(SQL_DIR,'segmentos.sql')) as query_file:
    query = query_file.read()

query = query.format(date_init = date_init,
                     date_end = date_end)


# Abrindo conexão com o banco
str_connection = "sqlite:///{path}"
str_connection = str_connection.format( path=os.path.join(DATA_DIR, "olist.db" ))
connection = sqlalchemy.create_engine( str_connection )

# Consulta (disparando uma query para o banco de dados)
df = pd.read_sql_query( query, connection )
create_query = f'''
create table tb_seller_sgmt as 
{query}
;'''

insert_query = f'''
delete from tb_seller_sgmt where DT_SGMT = '{date_end}';
insert into tb_seller_sgmt
{query}
;'''

try:
    connection.execute( create_query)
except:
    for q in insert_query.split(";")[:-1]:
        connection.execute( q )


