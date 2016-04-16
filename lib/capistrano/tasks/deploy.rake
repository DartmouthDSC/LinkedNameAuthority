# Custom Capistrano Tasks
namespace :deploy do 
  desc 'Write Cron Tab'
  task :write_crontab do
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :whenever, '-w'
        end
      end
    end
  end
    
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
end
