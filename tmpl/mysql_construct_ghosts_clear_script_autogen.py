#!/usr/bin/env python
import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-f", "--searchfiles",help="search for string in this file", nargs='+')

args = parser.parse_args()


# print(args.searchfiles)


pattern = re.compile("# REALLY_UNLIKELY_STRING_FROM_DATABASE_FIELD # \| (\d+)")

file_ids=[]
for file in args.searchfiles:
            for i, line in enumerate(open(file)):
                        for match in re.finditer(pattern, line):
                                    #                        print('Found on line %s: %s' % (i+1, match.groups()))
                                    file_ids.append(match.group(1))
                                    # print(file_ids)

# eliminate dups
file_ids=set(sorted(file_ids))

out=r'''UPDATE streambox_live.file SET is_active=0 WHERE file_id in ({csv});'''.format(csv=','.join(file_ids))

if len(file_ids) > 0:
            print(out)
