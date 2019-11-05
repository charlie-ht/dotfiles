#!/usr/bin/env python3

import sys, re

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


LOCK_LINE = re.compile(r"CHT: thread=(?P<thread>0x[a-fA-F0-9]+): object=(?P<obj>0x[a-fA-F0-9]+) (?P<fname>[a-zA-Z0-9_-]+):(?P<lineno>[0-9]+) (?P<lock_type>.*)")

def compliment_lock(lock_type):
    if lock_type == 'END_ENQUEUE':
        return 'START_ENQUEUE'
    if lock_type == 'END_WAIT':
        return 'START_WAIT'
    if lock_type == 'GST_API_UNLOCK':
        return 'GST_API_LOCK'
    if lock_type == 'GST_MANIFEST_UNLOCK':
        return 'GST_MANIFEST_LOCK'

    if lock_type == 'START_ENQUEUE':
        return 'END_ENQUEUE'
    if lock_type == 'START_WAIT':
        return 'END_WAIT'
    if lock_type == 'GST_API_LOCK':
        return 'GST_API_UNLOCK'
    if lock_type == 'GST_MANIFEST_LOCK':
        return 'GST_MANIFEST_UNLOCK'

class LockObject:
    def __init__(self, line, thread, obj, fname, lineno, lock_type):
        self.line = line
        self.thread = thread
        self.obj = obj
        self.fname = fname
        self.lineno = lineno
        self.lock_type = self.normalise_lock_type(lock_type)
        self.matched = False

    def normalise_lock_type(self, lock_type):
        if 'START_ENQUEUE' in lock_type: return 'START_ENQUEUE'
        if 'END_ENQUEUE' in lock_type: return 'END_ENQUEUE'
        if 'START_WAIT' in lock_type: return 'START_WAIT'
        if 'END_WAIT' in lock_type: return 'END_WAIT'
        if 'GST_API_LOCK' in lock_type: return 'GST_API_LOCK'
        if 'GST_API_UNLOCK' in lock_type: return 'GST_API_UNLOCK'
        if 'GST_MANIFEST_LOCK' in lock_type: return 'GST_MANIFEST_LOCK'
        if 'GST_MANIFEST_UNLOCK' in lock_type: return 'GST_MANIFEST_UNLOCK'
        return lock_type

    def __eq__(self, other):
        return self.thread == other.thread and \
            self.obj == other.obj and \
            self.lock_type == compliment_lock(other.lock_type)

    def is_lock_object(self):
        return 'ENQUEUE' in self.lock_type or \
        'WAIT' in self.lock_type or \
        'MANIFEST' in self.lock_type or \
        'API' in self.lock_type

    def __repr__(self):
        return "Line={} Thread={}, Object={}, location={}:{} type={}".format(
            self.line, self.thread, self.obj, self.fname, self.lineno, self.lock_type)

def analyze_locking(lines):
    locks = []

    for i, line in enumerate(lines):
        #print(line)
        m = re.match(LOCK_LINE, line)
        if not m:
            #print("Skipping ", line)
            locks.append(line)
            continue
        thread = m.group('thread')
        obj = m.group('obj')
        fname = m.group('fname')
        lineno = m.group('lineno')
        lock_type = m.group('lock_type')
        #print("{} {} {} {} {}".format(thread, obj, fname, lineno, lock_type))
        locks.append(LockObject(i,thread,obj,fname,lineno,lock_type))

    for i, lock in enumerate(locks):
        if type(lock) == str or lock.matched or not lock.is_lock_object():
            continue
        #print("Checking ", lock)
        for lock2 in locks[i+1:]:
            if type(lock2) == str or lock2.matched or not lock2.is_lock_object():
                continue
            #print("\tagainst ", lock2)
            if lock == lock2:
                lock.matched = lock2.matched = True
                lock.matched_by = lock2
                lock2.matched_by = lock
                #print("\tit's a match")
                break

    for lock in locks:
        if type(lock) == str or not lock.is_lock_object():
            print("Inline: ", lock)
            continue
        if lock.matched:
            print(bcolors.OKGREEN + "{}\n\tmatched by {}".format(lock, lock.matched_by) + bcolors.ENDC)
        else:
            print(bcolors.FAIL + "{} not matched!".format(lock) + bcolors.ENDC)

def main():
    try:
        filename = sys.argv[1]
    except:
        print("give me the log file name to process")
        sys.exit(1)
    with open(filename, errors="surrogateescape") as f:
        lines = f.readlines()
    analyze_locking(lines)


if __name__ == '__main__':
    sys.exit(main())
    filename = sys.argv[1]

    print(sys.path)
    sys.exit(1)

    with open(filename, 'r') as f:
        main(open.read())
