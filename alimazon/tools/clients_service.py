import sqlite3
from contextlib import contextmanager

class ClientsService(object):
    def __init__(self, database_path, table_name):
        self.database_path = database_path
        self.table_name = table_name

    def all(self):
        with sqlite3.connect(self.database_path) as connection:
            cursor = connection.cursor()
            # TODO: optimize to avoid loading everything into memory
            clients = list(cursor.execute('select * from {}'.format(self.table_name)))
            return clients

    def count(self):
        with sqlite3.connect(self.database_path) as connection:
            cursor = connection.cursor()
            results = cursor.execute('select count(*) from {}'.format(self.table_name))
            return int(results.fetchone()[0])


def run_clients_query():
    clients = ClientsService(
        database_path='./resources/clients/client.sqlite',
        table_name='client')

    count = 0
    for row in clients.all():
        count += 1
        print(row)

    print('{} clients registered'.format(count))


if __name__ == "__main__":
    run_clients_query()
