# Linked Name Authority

[![Build Status](https://travis-ci.org/DartmouthDSC/LinkedNameAuthority.svg?branch=develop)](https://travis-ci.org/DartmouthDSC/LinkedNameAuthority)
[![Coverage Status](https://coveralls.io/repos/github/DartmouthDSC/LinkedNameAuthority/badge.svg?branch=develop)](https://coveralls.io/github/DartmouthDSC/LinkedNameAuthority?branch=develop)

##Install notes for Development VMs

1. The Oracle client requires setting environment variables in ~/.bash_profile. Add this to that file before running bundle install:
    ```
    # Oracle Definitions.
    export ORACLE_BASE=/usr/lib/oracle
    export ORACLE_HOME=$ORACLE_BASE/12.1/client64

    export LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib:$LD_LIBRARY_PATH
    export PATH=/usr/lib/oracle/12.1/client64/bin:$PATH
    
    # Sets Characters Oracle is using.
    export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
    ```
2. Install all gem dependencies:
    ```
   bundle install
   ```
   Note: If running in *production* use `bundle install --without development test ci`

3. Once everything is installed, sync the db:
    ```
    rake db:migrate
    ```

4. Set environment variables in `.env` (You may need to create a new file). See 'Environment Variables' section below for a description of variables needed.

5. Load organizations, people (faculty) and documents:
   ```
   rake load:all
   ```
   
6. To write crontab:
   ```
   whenever -w
   ```
   
   **Note:** This will write the crontab under the current user running this command. If you would like the commands in the crontab to run in a different environment than `development`, either use the `--set` flag avaliable in `whenever` or set the rails environment before running the command `RAILS_ENV=qa whenever -w`.
   
## Deploying to QA
1. If this is the first time deploying to qa, **on qa.dac**
   - Create an empty folder at `/usr/local/dac/LinkedNameAuthority/shared` and `usr/local/dac/LinkedNameAuthority/shared/db`.
   - Create a file called `.env` in `/usr/local/dac/LinkedNameAuthority/shared` with necessary environment variables. See 'Environment Variables' section below for a list of required variables.
   - [may not have to do this] Create an empty file at `/usr/local/dac/LinkedNameAuthority/db/production.sqlite3

2. From your **development machine** run:
    ```
    bundle exec cap qa deploy
    ```

   This will checkout the `develop` branch of the application, run any migrations, compile assets, write the crontab and restart apache. 

3. If this is the first time deploying to qa, and you would like to load all the data without waiting for the cron job run:
   ```
   bundle exec cap deploy:load_data
   ```

##Environment Variables
Listed below are environment variables needed by the Linked Name Authority.
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

For qa and production environments, these additional variables are needed.
```
# Used to sign cookies. Create a new key by running `rake secret`.
# Required
SECRET_KEY_BASE=******************
```
