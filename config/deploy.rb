# config valid only for current version of Capistrano
lock '3.5'

set :application, 'LinkedNameAuthority'
set :repo_url, 'git@github.com:DartmouthDSC/LinkedNameAuthority.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, "/opt/deploy/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

set :linked_files, fetch(:linked_files, []).push('.env', 'db/production.sqlite3')

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
                                               'public/system')

set :default_env, {
      'LD_LIBRARY_PATH' => '/usr/lib/oracle/12.1/client64/lib:$LD_LIBRARY_PATH',
      'ORACLE_HOME'     => '/usr/lib/oracle/12.1/client64',
      'NLS_LANG'        => 'AMERICAN_AMERICA.WE8ISO8859P1'
    }

set :keep_releases, 5

set :bundle_without, %w{development test ci}.join(' ')

set :bundle_bins, fetch(:bundle_bins) + %w(whenever)

namespace :deploy do
  after :finished, "deploy:restart_apache"
  after :finished, "deploy:write_crontab"
end
