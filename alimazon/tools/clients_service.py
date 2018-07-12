import sqlite3
from contextlib import contextmanager

_DEFAULT_DATABASE_PATH='./resources/clients/client.sqlite'
_DEFAULT_TABLE_NAME='client'

class ClientsService(object):
    def __init__(self, database_path=_DEFAULT_DATABASE_PATH, table_name=_DEFAULT_TABLE_NAME):
        self.database_path = database_path
        self.table_name = table_name

    def all(self):
        with sqlite3.connect(self.database_path) as connection:
            cursor = connection.cursor()
            # TODO: optimize to avoid loading everything into memory
            clients = cursor.execute('select * from {}'.format(self.table_name))
            return clients

    def count(self):
        with sqlite3.connect(self.database_path) as connection:
            cursor = connection.cursor()
            results = cursor.execute('select count(*) from {}'.format(self.table_name))
            return int(results.fetchone()[0])

    # NOTE: This method (and others) are temporary and will most likely be replaced
    #       by a proper ORM if we ever turn this into a general purpose tool
    def where(self, condition):
        with sqlite3.connect(self.database_path) as connection:
            cursor = connection.cursor()
            clients = cursor.execute('select * from {table} where {condition}'.format(
                table=self.table_name,
                condition=condition))
            return clients


def _smoke_test():
    clients = ClientsService(
        database_path='./resources/clients/client.sqlite',
        table_name='client')

    count = 0
    for row in clients.where('registration_date >= "2018-04-19T20:19:00"'):
        count += 1
        print(row)

    print('{} clients registered'.format(count))


if __name__ == "__main__":
    _smoke_test()
