namespace :deploy do
  desc "Upload binary"
  task :upload do
    on release_roles :all do
      upload! "dist/bin/api", "#{release_path}/api"
      
      # within release_path do
      #   execute :chmod, '+x', 'run.sh'
      # end
    end
  end
end
