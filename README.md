# LinkedNameAuthority

[![Build Status](https://travis-ci.org/DartmouthDSC/LinkedNameAuthority.svg?branch=develop)](https://travis-ci.org/DartmouthDSC/LinkedNameAuthority)
[![Coverage Status](https://coveralls.io/repos/github/DartmouthDSC/LinkedNameAuthority/badge.svg?branch=develop)](https://coveralls.io/github/DartmouthDSC/LinkedNameAuthority?branch=develop)

Dartmouth Linked Name Authority Server

Install notes:

The Oracle client requires setting environment variables in .bash_profile. Add this to that file before running bundle install:

    # Oracle Definitions.
    export ORACLE_BASE=/usr/lib/oracle
    export ORACLE_HOME=$ORACLE_BASE/12.1/client64

    export LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib:$LD_LIBRARY_PATH
    export PATH=/usr/lib/oracle/12.1/client64/bin:$PATH

Once everything is installed, sync the db and load data using:

    rake db:migrate
    rake import:oracle_faculty
