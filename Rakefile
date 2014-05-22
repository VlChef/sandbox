#
# Rake tasks to test your cookbook
#
# Copyright (C) 2012-2013 Mathias Lafeldt <mathias.lafeldt@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/cookbook/metadata'
require 'ci/reporter/rake/rspec'

def cookbook_metadata
  metadata = Chef::Cookbook::Metadata.new
  metadata.from_file 'metadata.rb'
  metadata
end

def cookbook_name
  name = cookbook_metadata.name
  if name.nil? || name.empty?
    File.basename(File.dirname(__FILE__))
  else
    name
  end
end

COOKBOOK_NAME = ENV['COOKBOOK_NAME'] || cookbook_name
COOKBOOKS_PATH = ENV['COOKBOOKS_PATH'] || 'cookbooks'

task :setup_cookbooks do
  rm_rf COOKBOOKS_PATH
  sh 'berks', 'install', '--path', COOKBOOKS_PATH

  # Remove the '.gems' containing gems installed by Bundler and copied by
  # Berkshelf.
  # Otherwise, some tools will attempt to validate the gems inside of it and
  # fail in some cases.
  FileUtils.rm_rf "#{COOKBOOKS_PATH}/#{COOKBOOK_NAME}/.gems"
end

desc 'Run knife cookbook test'
task :knife => :setup_cookbooks do
  sh 'knife', 'cookbook', 'test', COOKBOOK_NAME, '--config', '.knife.rb',
     '--cookbook-path', COOKBOOKS_PATH
end

desc 'Run Foodcritic lint checks'
task :foodcritic => :setup_cookbooks do
  sh 'foodcritic', '--epic-fail', 'any',
     File.join(COOKBOOKS_PATH, COOKBOOK_NAME)
end

desc 'Run ChefSpec examples'
task :chefspec => [:setup_cookbooks, 'ci:setup:rspec'] do
  sh 'rspec', '--color', '--format', 'documentation',
    File.join(COOKBOOKS_PATH, COOKBOOK_NAME, 'spec')
end

desc 'Run Rubocop'
task :rubocop do
  sh 'rubocop', '-fs'
end

desc 'Run all tests'
task :test => [:knife, :foodcritic, :chefspec, :rubocop]

task :default => :test

desc 'Create a new release'
task :release, :version do |t, args|
  raise 'Release task requires a version number' if args.version.nil?

  update_metadata_version('metadata.rb', args.version)

  # Run tests after merging the changes from next. Saves a lot of hassle.
  Rake::Task['test'].invoke

  sh 'git', 'commit', 'metadata.rb', '-m', "Increasing version number to #{args.version}"

  sh 'git', 'push', 'origin', 'HEAD:next'

  sh 'git', 'checkout', 'master'

  sh 'git', 'merge', '--no-ff', '--log', 'remotes/origin/next'

  sh 'git', 'tag', "v#{args.version}"

  sh 'git', 'push', 'origin', 'HEAD:master'
  sh 'git', 'push', 'origin', 'HEAD:master', '--tags'
end

# aliases
task :lint => :foodcritic

# Cleanup testing cookbooks
at_exit { rm_rf COOKBOOKS_PATH }

def update_metadata_version(file, version)
  # Read the metadata file
  metadata_content = File.read(file)
  # Find the line describing the version
  version_line_match = /^version\s+'(\d\.\d\.\d)'$/.match(metadata_content)
  version_line = version_line_match[0]

  old_version = version_line_match[1]

  if Gem::Version.new(version) < Gem::Version.new(old_version)
    raise "Given version string '#{version}' is older than the current " \
      "version '#{old_version}'"
  end

  # Replace the old version with the new one in the line describing the version
  updated_version_line = version_line.gsub(/#{old_version}/, version)
  # Replace the old line with the new one
  new_metadata_content = metadata_content.gsub(/#{version_line}/, updated_version_line)
  # Wirte the updated content to the file
  File.write(file, new_metadata_content)
end
