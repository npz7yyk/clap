#!/bin/env python3
from collections import defaultdict

file_name = "profile_branch.log"
output = "branch_count.log"
pc2idex = defaultdict()
total = {"id": 0, "ex": 0, "all": 0}
with open("./" + file_name.strip()) as file:
    for line in file:
        type_pc_status = line.strip().split(" ")
        type = type_pc_status[0]
        pc = int(type_pc_status[1],16)
        status = type_pc_status[2]
        if pc not in pc2idex.keys():
            pc2idex[pc] = {"id": 0, "ex": 0, "all": 0}
        pc2idex[pc]["all"] += 1 
        pc2idex[pc][type] += int(status)
        total["all"] += 1
        total[type] += int(status)

with open(output, mode="w") as out:
    print(r"             all    id     ex     id_ratio ex_ratio all_ratio",file=out)
    all = total["all"]
    id = total["id"]
    ex = total["ex"]
    ratio_ex = ex / all * 100
    ratio_id = id / all * 100
    ratio = ratio_ex + ratio_id
    print("total:       %6d %6d %6d  %6.2f%%  %6.2f%%   %6.2f%%" % (all,id,ex,ratio_id,ratio_ex,ratio),file=out)
    for pc in pc2idex.keys():
        all = pc2idex[pc]["all"]
        id = pc2idex[pc]["id"]
        ex = pc2idex[pc]["ex"]
        ratio_ex = ex / all * 100
        ratio_id = id / all * 100
        ratio = ratio_ex + ratio_id
        print("pc=%08x: %6d %6d %6d  %6.2f%%  %6.2f%%   %6.2f%%" % (pc,all,id,ex,ratio_id,ratio_ex,ratio),file=out)
