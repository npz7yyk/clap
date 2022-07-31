#!/bin/env python3

from collections import defaultdict

file_name = input()
count = defaultdict()
with open(file_name) as file:
    for line in file:
        if ":" not in line or "<" in line:
            continue
        line.replace(":", "")
        try:
            line_set = line.split("\t")
            t = line_set[2].strip()
        except BaseException:
            continue
        if t[0] == "0":
            continue
        if t not in count.keys():
            count[t] = 0
        count[t] += 1

with open("type_extract.txt", "w") as file:
    for key in count.keys():
        print(f"{key}\t\t{count[key]}", file=file)
