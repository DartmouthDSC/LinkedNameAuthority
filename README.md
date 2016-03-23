# Linked Name Authority

[![Build Status](https://travis-ci.org/DartmouthDSC/LinkedNameAuthority.svg?branch=develop)](https://travis-ci.org/DartmouthDSC/LinkedNameAuthority)
[![Coverage Status](https://coveralls.io/repos/github/DartmouthDSC/LinkedNameAuthority/badge.svg?branch=develop)](https://coveralls.io/github/DartmouthDSC/LinkedNameAuthority?branch=develop)

##Install notes

1. The Oracle client requires setting environment variables in .bash_profile. Add this to that file before running bundle install:
    ```
    # Oracle Definitions.
    export ORACLE_BASE=/usr/lib/oracle
    export ORACLE_HOME=$ORACLE_BASE/12.1/client64

    export LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib:$LD_LIBRARY_PATH
    export PATH=/usr/lib/oracle/12.1/client64/bin:$PATH
    ```
2. Install all gem dependencies:
    ```
   bundle install
   ```

3. Once everything is installed, sync the db:
    ```
    rake db:migrate
    ```

4. Set the following environmental variables in `.env` (You may need to create a new file):
   ```
   # Email list used by loaders to send email notifications about warnings and errors.
   # Optional
   LOADER_NOTICES=me@example.com

   # Email list used by loaders to send email notifications about errors.
   # Required
   LOADER_ERROR_NOTICES=me@example.com,me.too@examples.com

   # Email to send cron errors
   # Required
   # CRON_EMAIL_NOTICES=me@example.com

   # Credentials for Elements
   # Required
   ELEMENTS_USERNAME=******
   ELEMENTS_PASSWORD=*********

   # Credentials for Oracle.
   # Required
   LNA_ORACLE_USERNAME=****
   LNA_ORACLE_PASSWORD=********
   ```

5. Load organizations, people (faculty) and documents:
    ```
   rake load:all
   ```
