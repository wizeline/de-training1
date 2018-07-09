import contextlib
import os

# TODO: implement unit tests
# TODO: document functions more thoroughly

def add_extension_if_missing(filepath, new_extension):
    path, extension = os.path.splitext(filepath)
    if len(extension.lstrip('.')) == 0:
        return '{filepath}.{extension}'.format(
            filepath=filepath.rstrip('.'), extension=new_extension.lstrip('.'))
    return filepath


def remove_last_extension(filepath):
    """
    remove_last_extension('file.csv.gz') => 'file.csv'
    """
    path, extension = os.path.splitext(filepath)
    return path


def ensure_file_extension(filepath, extension):
    """
    ensure_file_extension('file.csv', 'csv') => 'file.csv'
    ensure_file_extension('file.csv', 'gz') => 'file.csv.gz'
    """
    if filepath.endswith(extension):
        return filepath
    return '{filepath}.{extension}'.format(filepath=filepath, extension=extension)


def replace_extension(filepath, new_extension):
    """
    replace_extension('file.csv', 'tsv') => 'file.tsv'
    replace_extension('file.csv.gz', 'tsv') => 'file.tsv'
    """
    path, extension = os.path.splitext(filepath)
    while len(extension) > 0:
        path, extension = os.path.splitext(path)

    return '{0}.{1}'.format(path, new_extension.lstrip('.'))


def split_extensions(filepath):
    extensions = []
    path, extension = os.path.splitext(filepath)
    while len(extension) > 0:
        extensions.insert(0, extension)
        path, extension = os.path.splitext(path)
    return path, ''.join(extensions)


def replace_filename_sans_extension(filepath, new_name):
    """
    replace_filename_sans_extension('/users/home/file.tsv.gz', 'files')
       => '/users/home/files.tsv.gz'
    """
    filepath, filename = os.path.split(filepath)
    name, extensions = split_extensions(filename)
    return os.path.join(filepath, '{name}{extensions}'.format(
        name=new_name, extensions=extensions))


def replace_filename(filepath, new_name):
    """
    replace_filename('/users/home/file.tsv.gz', 'file')
       => '/users/home/file'
    """
    filepath, filename = os.path.split(filepath)
    return os.path.join(filepath, new_name)


def prepend_to_filename(filepath, prefix):
    """
    prepend_to_filename('/users/home/file.tsv.gz', 'temp')
       => '/users/home/temp_file.tsv.gz'
    """
    filepath, filename = os.path.split(filepath)
    return os.path.join(filepath, prefix + filename)


def delete_file(filepath, raise_on_error=True):
    try:
        os.remove(filepath)
        return True
    except OSError:
        if raise_on_error:
            raise
    return False


@contextlib.contextmanager
def temporary_file_rename(full_filepath, new_name):
    """
    print(path) # => '/users/home/clients.txt'
    with temporary_file_rename('/users/home/clients.txt', 'customers.csv') as path:
       print(path) # => '/users/home/customers.csv'
    print(path) # => '/users/home/clients.txt'
    """
    new_full_filepath = replace_filename(full_filepath, new_name)

    os.rename(full_filepath, new_full_filepath)
    yield new_full_filepath
    os.rename(new_full_filepath, full_filepath)
