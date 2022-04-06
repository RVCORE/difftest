#!/usr/bin/python3
"""
author: yangye
describe: get realpath of file that is a list from first argument for the python script
Write all source files in the file to a txt document file
"""
from ast import parse
import sys
import os

def create_file_list(dst_path, lst, prefix):
  with open(dst_path, 'w') as dst:
    for name in lst:
      dst.write(f"{prefix}{name}\n")

def get_real_path(file):
  return os.path.dirname(file)+"/"

def read_file(file):
  # print("open file=", file)
  file_list = []
  dir = get_real_path(file)
  with open(file, "r") as fp:
    for line in fp.readlines():
      line = line.strip('\n')
      strs = line.split(' ', 1)
      #print(strs)
      # parse string of a line
      
      if strs[0].startswith("//"):# if // ...
        continue
      elif strs[0].startswith("-F"):# if -F 
        file_list += read_file(dir+strs[1])
      else:
        new_list = [dir + x for x in strs if isinstance(x, str)]
        file_list += new_list
  fp.close()
  return file_list


# check args
if len(sys.argv) == 0:
  print("[Error]: no args")
  exit(1)

flist = str(sys.argv[1])
print("will read file list: ", flist)
all_file = read_file(flist)
create_file_list("./compile_emu_flist.txt", all_file, "")