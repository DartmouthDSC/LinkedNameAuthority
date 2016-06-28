# Custom Capistrano Tasks
namespace :deploy do 
  desc 'Restart Apache'
  task :restart_apache do
    on roles(:app, :web) do
      execute 'sudo /sbin/service httpd restart'
    end
  end

  desc 'Load organizations, people and documents'
  task :load_data do 
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :rake, 'load:all'
        end
      end
    end
  end

  desc 'Reindex all documents in Solr'
  task :reindex do
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :rake, 'lna:reindex'
        end
      end
    end
  end

  desc 'Seed db with roles and users'
  task :seed_db do
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :rake, 'db:seed'
        end
      end
    end
  end
end
