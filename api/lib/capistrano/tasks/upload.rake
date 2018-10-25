namespace :deploy do
  desc "Upload binary"
  task :upload do
    on release_roles :all do
      upload! "dist/bin/api.tar.gz", "#{release_path}/api.tar.gz"
      
      within release_path do
        execute :tar, '-zxvf', "api.tar.gz"
        # execute :chmod, '+x', 'run.sh'
      end
    end
  end
end
