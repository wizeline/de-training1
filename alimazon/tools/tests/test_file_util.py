from file_util import add_extension_if_missing


def test__add_extension_if_missing():
    # file names without extension should get a new extension
    assert add_extension_if_missing('file', 'txt') == 'file.txt'
    assert add_extension_if_missing('file', '.txt') == 'file.txt'

    # file paths without extension should get a new extension
    assert add_extension_if_missing('/home/me/file', '.txt') == '/home/me/file.txt'
    assert add_extension_if_missing('/home/me/file.', '.txt') == '/home/me/file.txt'

    # files with an extension should be left untouched
    assert add_extension_if_missing('file.csv', 'txt') == 'file.csv'
    assert add_extension_if_missing('file.csv', '.txt') == 'file.csv'

    # hidden files (which start with ".") can also get an extension
    assert add_extension_if_missing('.bashrc', '.backup') == '.bashrc.backup'
