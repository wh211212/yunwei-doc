#/usr/bin/python
#coding:utf-8

from contextlib import contextmanager
import sys
import json
import logging
#
# Import salt libs
import salt.returners
import salt.utils.jid
import salt.exceptions

# Import third party libs
try:
    import MySQLdb
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

log = logging.getLogger(__name__)

# Define the module's virtual name
__virtualname__ = 'mysql'

def __virtual__():
    if not HAS_MYSQL:
        return False
    return 'mysql'

def _get_options():
    '''
    Returns options used for the MySQL connection.
    '''
    defaults = {'host': '10.1.1.97',
                'user': 'salt',
                'pass': 'salt',
                'db': 'salt',
                'port': 3306}
    _options = {}
    for attr in defaults:
        _attr = __salt__['config.option']('mysql.{0}'.format(attr))
        if not _attr:
            log.debug('Using default for MySQL {0}'.format(attr))
            _options[attr] = defaults[attr]
            continue
        _options[attr] = _attr
    return _options

@contextmanager
def _get_serv(commit=False):
    '''
    Return a mysql cursor
    '''
    _options = _get_options()

    conn = MySQLdb.connect(host=_options['host'], user=_options['user'], passwd=_options['pass'], db=_options['db'], port=_options['port'])
    cursor = conn.cursor()
    try:
        yield cursor
    except MySQLdb.DatabaseError as err:
        error, = err.args
        sys.stderr.write(error.message)
        cursor.execute("ROLLBACK")
        raise err
    else:
        if commit:
            cursor.execute("COMMIT")
        else:
            cursor.execute("ROLLBACK")
    finally:
        conn.close()

def returner(ret):
    '''
    Return data to a mysql server
    '''
    with _get_serv(commit=True) as cur:
        sql = '''INSERT INTO `salt_returns`
                (`fun`, `jid`, `return`, `id`, `success`, `full_ret` )
                VALUES (%s, %s, %s, %s, %s, %s)'''
        cur.execute(sql, (ret['fun'], ret['jid'],
                            str(ret['return']), ret['id'],
                            ret['success'], json.dumps(ret)))
