require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']
# A sample Gemfile
source "http://rubygems.org"

gem 'guard'
gem "guard-coffeescript"
gem "guard-bundler"
case HOST_OS
  when /darwin/i
    gem 'rb-fsevent'
    gem 'growl'
  when /linux/i
    gem 'libnotify'
    gem 'rb-inotify'
  when /mswin|windows/i
    gem 'rb-fchange'
    gem 'win32console'
    gem 'rb-notifu'
end

