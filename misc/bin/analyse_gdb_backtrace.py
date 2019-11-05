#!/usr/bin/env python3

# This script takes the output of thread apply all bt and filters away
# the uninteresting bits, since there can be hundred of threads.  I
# want to use the GDB python interface to make this less of a hassle.
# See https://github.com/python/cpython/blob/master/Tools/gdb/libpython.py
# and https://sourceware.org/gdb/current/onlinedocs/gdb/Python.html#Python

import itertools, pprint

class AThread:
    def __init__(self,info,bts):
        self.info = info
        self.bts = bts
    @property
    def is_ffmpeg_worker(self):
        for bt in self.bts:
            if 'frame_worker' in bt:
                return True
        return False
    @property
    def is_radeonsi_dri(self):
        for bt in self.bts:
            if 'radeonsi_dri.so' in bt:
                return True
        return False
    def __repr__(self):
        return '\n{}\n{}'.format(self.info,''.join(self.bts))

def parse_thread_trace(thr):
    tmp=thr.split('#')
    thread_info=tmp[0]
    bts=tmp[1:]
    return AThread(thread_info,bts)

d = open('threads.log')
data=d.read()
threads=list(map(parse_thread_trace,data.split("\n\n")))
print("processing {} threads".format(len(threads)))
print("there are {} ffmpeg workers".format(len(list(filter(lambda t: t.is_ffmpeg_worker, threads)))))
print("there are {} radeonsi workers".format(len(list(filter(lambda t: t.is_radeonsi_dri, threads)))))
of_interest = list(itertools.filterfalse(lambda t: t.is_ffmpeg_worker or t.is_radeonsi_dri, threads))
print("{} to analyze".format(len(of_interest)))
pprint.pprint(of_interest)
