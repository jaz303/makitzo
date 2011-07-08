# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{makitzo}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jason Frame"]
  s.date = %q{2011-07-08}
  s.default_executable = %q{makitzo}
  s.email = %q{jason@onehackoranother.com}
  s.executables = ["makitzo"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.mdown"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.mdown",
    "RESOURCES",
    "Rakefile",
    "VERSION",
    "bin/makitzo",
    "lib/makitzo.rb",
    "lib/makitzo/application.rb",
    "lib/makitzo/application_aware.rb",
    "lib/makitzo/cli.rb",
    "lib/makitzo/config.rb",
    "lib/makitzo/file_system.rb",
    "lib/makitzo/logging/blackhole.rb",
    "lib/makitzo/logging/collector.rb",
    "lib/makitzo/logging/colorize.rb",
    "lib/makitzo/memoized_proc.rb",
    "lib/makitzo/migrations/commands.rb",
    "lib/makitzo/migrations/generator.rb",
    "lib/makitzo/migrations/migration.rb",
    "lib/makitzo/migrations/migrator.rb",
    "lib/makitzo/migrations/paths.rb",
    "lib/makitzo/monkeys/array.rb",
    "lib/makitzo/monkeys/bangify.rb",
    "lib/makitzo/monkeys/net-ssh.rb",
    "lib/makitzo/monkeys/string.rb",
    "lib/makitzo/multiplexed_reader.rb",
    "lib/makitzo/settings.rb",
    "lib/makitzo/ssh/commands/apple.rb",
    "lib/makitzo/ssh/commands/file_system.rb",
    "lib/makitzo/ssh/commands/file_transfer.rb",
    "lib/makitzo/ssh/commands/http.rb",
    "lib/makitzo/ssh/commands/makitzo.rb",
    "lib/makitzo/ssh/commands/ruby.rb",
    "lib/makitzo/ssh/commands/unix.rb",
    "lib/makitzo/ssh/context.rb",
    "lib/makitzo/ssh/multi.rb",
    "lib/makitzo/store/mysql.rb",
    "lib/makitzo/store/skeleton.rb",
    "lib/makitzo/world/host.rb",
    "lib/makitzo/world/named_entity.rb",
    "lib/makitzo/world/query.rb",
    "lib/makitzo/world/role.rb",
    "makitzo.gemspec",
    "templates/migration.erb",
    "test/helper.rb",
    "test/test_makitzo.rb"
  ]
  s.homepage = %q{http://github.com/jaz303/makitzo}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{the swiss army knife of remote host manipulation}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0.2"])
      s.add_runtime_dependency(%q<net-ssh>, ["~> 2.1.0"])
      s.add_runtime_dependency(%q<net-scp>, ["~> 1.0.4"])
      s.add_runtime_dependency(%q<highline>, ["~> 1.6.1"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3.0.2"])
      s.add_dependency(%q<net-ssh>, ["~> 2.1.0"])
      s.add_dependency(%q<net-scp>, ["~> 1.0.4"])
      s.add_dependency(%q<highline>, ["~> 1.6.1"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.0.2"])
    s.add_dependency(%q<net-ssh>, ["~> 2.1.0"])
    s.add_dependency(%q<net-scp>, ["~> 1.0.4"])
    s.add_dependency(%q<highline>, ["~> 1.6.1"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

