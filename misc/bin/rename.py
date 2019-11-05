#!/usr/bin/env python3

# ./rename.py <pattern> <replacement> <top-level directory>
# Rename all files found in <top-level directory> that contain the
# regular expr. <pattern> with <replacement>
import os, sys, re

top_level_dir = sys.argv[1]
pattern = sys.argv[2]
replacement = sys.argv[3]

for root, dirs, files, rootfd in os.fwalk(sys.argv[1]):
#    print(root, dirs, files)
    for name in files:
        new_name, num_replacements = re.subn(pattern, replacement, name)
        if num_replacements > 0:
            print("rename {}/{} to {}/{}".format(root, name, root, new_name))
            os.replace(name, new_name, src_dir_fd=rootfd, dst_dir_fd=rootfd)
    continue
    print(root, "consumes", end="")
    print(sum([os.stat(name, dir_fd=rootfd).st_size for name in files]),
          end="")
    print("bytes in", len(files), "non-directory files")
    if 'CVS' in dirs:
        dirs.remove('CVS')  # don't visit CVS directories
