#  -*- coding:utf-8 -*-

import configparser
import pymysql
import sys


def get_db():
    cf = configparser.ConfigParser()
    cf.read('config.ini', encoding='utf-8')
    conn = pymysql.connect(
        host=cf.get('DATABASE', 'host'),
        user=cf.get('DATABASE', 'user'),
        passwd=cf.get('DATABASE', 'passwd'),
        db=cf.get('DATABASE', 'database'),
        port=cf.getint('DATABASE', 'port'),
        charset="utf8",
    )
    return conn


def update(conn, fullpath):
    cur = conn.cursor()
    sql = "update mysql.parents set tel = '3333333' where id = '%s'"
    with open('%s' % fullpath, "r") as file:
        for data in file:
            data = data.strip("\n")
            try:
                cur.execute(sql % data)
            except:
                conn.rollback()
                print("ip: %s Failed" % data)
            else:
                conn.commit()
                print("ip: %s Success" % data)

    cur.close()
    conn.close()


if __name__ == '__main__':
    filename = sys.argv[1]
    db = get_db()
    update(db, filename)
