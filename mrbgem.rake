DEFS_FILE = File.expand_path('../src/REVISIONS.defs', __FILE__) unless defined?(DEFS_FILE)
DEPENDENT_GEMS = Dir.glob(File.expand_path('../mruby/build/mrbgems/mruby-*', __FILE__)) unless defined?(DEPENDENT_GEMS)

MRuby::Gem::Specification.new('haconiwa') do |spec|
  spec.license = 'GPL v3'
  spec.authors = 'Uchio Kondo'

  spec.bins = ["haconiwa"]

  spec.add_dependency 'mruby-array-ext' , :core => 'mruby-array-ext'
  spec.add_dependency 'mruby-bin-mruby' , :core => 'mruby-bin-mruby'
  #spec.add_dependency 'mruby-bin-mirb'  , :core => 'mruby-bin-mirb'
  spec.add_dependency 'mruby-eval'      , :core => 'mruby-eval'
  spec.add_dependency 'mruby-random'    , :core => 'mruby-random'
  spec.add_dependency 'mruby-string-ext', :core => 'mruby-string-ext'
  spec.add_dependency 'mruby-io'        , :core => 'mruby-io'
  spec.add_dependency 'mruby-socket'    , :core => 'mruby-socket'
  if Dir.exist?(File.join(MRUBY_ROOT, "mrbgems", "mruby-metaprog"))
    spec.add_dependency 'mruby-metaprog'  , :core => 'mruby-metaprog'
  end

  spec.add_dependency 'mruby-shellwords', :mgem => 'mruby-shellwords'
  spec.add_dependency 'mruby-capability', :mgem => 'mruby-capability'
  spec.add_dependency 'mruby-cgroup'    , :mgem => 'mruby-cgroup'
  spec.add_dependency 'mruby-dir'       , :mgem => 'mruby-dir' # with Dir#chroot
  spec.add_dependency 'mruby-env'       , :mgem => 'mruby-env'
  spec.add_dependency 'mruby-linux-namespace', :mgem => 'mruby-linux-namespace'
  spec.add_dependency 'mruby-process'   , :github => 'iij/mruby-process'
  spec.add_dependency 'mruby-forwardable', :mgem => 'mruby-forwardable'
  spec.add_dependency 'mruby-seccomp'   , :github => 'chikuwait/mruby-seccomp'
  spec.add_dependency 'mruby-apparmor'  , :github => 'haconiwa/mruby-apparmor'

  spec.add_dependency 'mruby-onig-regexp', :github => 'mattn/mruby-onig-regexp'
  spec.add_dependency 'mruby-argtable'  , :github => 'udzura/mruby-argtable', :branch => 'static-link-argtable3'
  spec.add_dependency 'mruby-exec'      , :github => 'haconiwa/mruby-exec'
  spec.add_dependency 'mruby-mount'     , :github => 'haconiwa/mruby-mount'
  spec.add_dependency 'mruby-process-sys', :github => 'haconiwa/mruby-process-sys'
  spec.add_dependency 'mruby-procutil'  , :github => 'haconiwa/mruby-procutil'
  spec.add_dependency 'mruby-resource'  , :github => 'harasou/mruby-resource'
  spec.add_dependency 'mruby-cgroupv2'  , :github => 'haconiwa/mruby-cgroupv2'
  spec.add_dependency 'mruby-lockfile', :github => 'udzura/mruby-lockfile'
  spec.add_dependency 'mruby-fibered_worker' , :github => 'udzura/mruby-fibered_worker'
  spec.add_dependency 'mruby-eventfd' , :github => 'matsumotory/mruby-eventfd'
  spec.add_dependency 'mruby-file-listen-checker', github: 'pyama86/mruby-file-listen-checker'
  spec.add_dependency 'mruby-ifaddr', github: 'pyama86/mruby-ifaddr'

  spec.add_dependency 'mruby-syslog'    , :github => 'udzura/mruby-syslog'
  spec.add_dependency 'mruby-sha1', :github => 'mattn/mruby-sha1'

  spec.add_test_dependency 'mruby-cache', :github => 'matsumotory/mruby-localmemcache'

  # The good luck charm for avoiding dependency hell
  spec.add_dependency 'mruby-time'      , :core => 'mruby-time'
  spec.add_dependency 'mruby-sprintf'   , :core => 'mruby-sprintf'
  spec.add_dependency 'mruby-print'     , :core => 'mruby-print'


  spec.add_dependency 'mruby-subaco', github: 'oss-fun/mruby-subaco'
  if spec.build.cc.defines.flatten.include?("HACONIWA_USE_CRIU")
    spec.add_dependency 'mruby-criu', :github => 'matsumotory/mruby-criu'
  end

  def spec.save_dependent_mgem_revisions
    file DEFS_FILE => (DEPENDENT_GEMS + ["#{MRUBY_ROOT}/.git/packed-refs"]) do
      f = open(DEFS_FILE, 'w')
      corerev = `git rev-parse HEAD`.chomp
      f.puts %Q<{"MRUBY_CORE_REVISION", "#{corerev}"},>
      mygems = ["../"] # Parent of mruby/ - haconiwa.gem
      mygems += `find ./build/mrbgems -type d -name 'mruby-*' | sort`.lines
      mygems.each do |l|
        l = l.chomp
        if File.directory? "#{l}/.git"
          gemname = l.split('/').last
          gemname = "haconiwa" if gemname == '..'
          rev = `git --git-dir #{l}/.git rev-parse HEAD`.chomp
          f.puts %Q<{"#{gemname}", "#{rev}"},>
        end
      end
      f.close
      puts "GEN\t#{DEFS_FILE}"
    end

    libmruby_a = libfile("#{build.build_dir}/lib/libmruby")
    file libmruby_a => DEFS_FILE
  end

  spec.save_dependent_mgem_revisions

  spec.build.cc.flags << "-DMRB_THREAD_COPY_VALUES"
end
