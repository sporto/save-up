namespace :deploy do
  desc "Restart"
  task :restart do
    on release_roles :all do

      execute :kill, "-9 $(lsof -i tcp:80 -t)"
      # pid = capture 'lsof', '-i:80 -t', raise_on_non_zero_exit: false

      # if pid.present?
      #   execute "kill -9 #{pid}"
      # end

      within release_path do
        execute "./api &"
      end
    end
  end
end

after "deploy:published", "restart"
