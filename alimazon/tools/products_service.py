import random
import csv
from collections import namedtuple

from iter_util import take
from file_util import open_file


_DEFAULT_DATASET_PATH='./resources/amazon_products.tsv.gz'

# TODO: should we also move this to SQLite and load it from there?
Product = namedtuple('Product', ['id', 'title', 'category'])
class ProductsService(object):
    def __init__(self, dataset_path=_DEFAULT_DATASET_PATH):
        self.dataset_path = dataset_path
        self.products = self.load_products_subset(dataset_path, size=100000)

    def all(self):
        return self.products

    def choose_random(self):
        return random.choice(self.products)

    def load_products_subset(self, dataset_path, size):
        products = []
        with open_file(dataset_path, mode='rt') as csvfile:
            reader = csv.DictReader(csvfile, delimiter='\t')
            for row in take(size, reader):
                product = Product(id=row['product_id'],
                                  title=row['product_title'],
                                  category=row['product_category'])
                products.append(product)
        return products


def _smoke_test():
    products_service = ProductsService()
    print('{} products loaded'.format(len(products_service.all())))
    for _ in range(10):
        print(products_service.choose_random())
    print('...')


if __name__ == '__main__':
    _smoke_test()
