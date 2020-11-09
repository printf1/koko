#  -*- coding:utf-8 -*-

import os
import pymysql
import configparser
import uuid
import time
import sys

'''
Environment_Code
   TL:BRN_PRODUCTION
   CS:DEVELOPMENT_TEST
   LJ:PRODUCTION_LJ-PRO
   ZB:DISASTER_RECOVERY_PER-PRODUCTION
'''

TL = "BRN_PRODUCTION"
LJ = "PRODUCTION_LJ-PRO"
CS = "DEVELOPMENT_TEST"
ZB = "DISASTER_RECOVERY_PER-PRODUCTION"
L = "Linux"
W = "windows"


def connect():
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
    return conn, cf.get('DATABASE', 'host')


def insert(conn, fullpath, env, os):
    cur = conn.cursor()
    with open('%s' % fullpath, "r") as file:
        for data in file:
            data = data.strip("\n")
            a = data + " %s" % os + " %s" % env
            sql = get_sql(a)
            try:
                cur.execute(sql)
            except:
                conn.rollback()
                print("ip: %s Failed" % data)
            else:
                conn.commit()
                print("ip: %s Success" % data)
    cur.close()
    conn.close()


def get_sql(a):
    myname = "admin"
    nowtime = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time()))
    ct = time.time()
    data_secs = (ct - int(ct)) * 1000
    time_stamp = "%s.%03d" % (nowtime, data_secs)
    x = a.split(" ")                                                
    uxid = uuid.uuid1().hex
    sql = '''INSERT INTO `otps`.`t_host_info` (`ID`, `APP_ID`, `IP_ADDRESS`, `SERVER_TYPE`, `SYSTEM_TYPE`, `OS_DISTRO`, `REMOTE_PORT`, `ENVIROMENT`, `MONITOR_INGOR_START_TIME`,`MONITOR_INGOR_END_TIME`,`CREATED_BY`,`CREATED_TIME`,`LAST_MODIFIED_BY`,`LAST_MODIFIED_TIME`,`status`,`SYSTEM_ID`,`BSYS_ID`,`DATA_TYPE`,`HEALTH`,`area_name`,`OS_TYPE`) VALUES ('{0}', NULL, '{1}', NULL, '{2}', NULL, '4759','{3}',NULL,NULL,'{4}','{5}','{4}','{5}','ONLINE', NULL, NULL, NULL, '1', '', '0');'''.format(
        uxid, x[0], x[1], x[2], myname, time_stamp)
    return sql


if __name__ == '__main__':

    OS_CODE = sys.argv[1]
    OS_TYPE = sys.argv[2]
    fullpath = sys.argv[3]
    if OS_CODE == "TL":
        env = TL
    elif OS_CODE == "LJ":
        env = LJ
    elif OS_CODE == "CS":
        env = CS
    elif OS_CODE == "ZB":
        env = ZB
    else:
        print("arguments format error")

    if OS_TYPE == "L":
        os = L
    elif OS_TYPE == "W":
        os = W
    else:
        print("arguments format error")

    conn, host = connect()
    insert(conn, fullpath, env, os)
