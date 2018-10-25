namespace :deploy do
  desc "Upload binary"
  task :upload do
    on release_roles :all do
      tarfile = "api.tar.gz"

      upload! "dist/bin/#{tarfile}", "#{release_path}/#{tarfile}"
      
      within release_path do
        execute :tar, '-zxvf', tarfile
        execute :rm, tarfile
        # execute :chmod, '+x', 'run.sh'
      end
    end
  end
end
