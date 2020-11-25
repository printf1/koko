#!/usr/bin/python
import sys

def main():
    revert_2_result = '|$|'.join([bin(ord(c)).replace('0b', '') for c in str])
    print(revert_2_result)
    return revert_2_result


if __name__ == '__main__':
    str = sys.argv[1]
    main()

