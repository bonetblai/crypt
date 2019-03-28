#!/bin/bash

python -c "import sys;s=list(sys.argv[1])[:-1];s[3]=s[7]='-';print ''.join(s)" `openssl rand -hex 6`

