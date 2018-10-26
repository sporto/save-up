namespace :deploy do
  desc "Restart"
  task :restart do
    on release_roles :all do

      # pid = capture 'lsof', '-i:80', '-t'
      # if pid # ensure it's valid here
      #   run "kill -9 #{pid}"
      # end

      # run "./api"

    end
  end
end

after "deploy:published", "restart"
