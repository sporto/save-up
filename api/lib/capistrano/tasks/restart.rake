namespace :deploy do
  desc "Restart"
  task :restart do
    on release_roles :all do

      execute :kill, "-9 $(lsof -i tcp:80 -t)"

      within release_path do
        # nohup ./api 2>&1 >> /app/shared/api.log &
        # execute "./api", "& sleep 5"
        # execute :nohup, "./api 2>&1 >> /app/shared/api.log &", pty: false
        execute :nohup, "./api >> /app/shared/api.log 2>&1 &", pty: false
      end
    end
  end
end

after "deploy:published", "restart"
