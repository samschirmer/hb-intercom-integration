#!/bin/bash --login

export PWD=/home/sschirmer/crons/intercom
export GEM_HOME=/home/sschirmer/.rvm/gems/ruby-2.5.5
export SHELL=/bin/bash
export USER=sschirmer
export LOGNAME=sschirmer

export rvm_path=/home/sschirmer/.rvm
export rvm_prefix=/home/sschirmer
export PATH=/home/sschirmer/.rvm/wrappers/ruby-2.5.5/ruby:/home/sschirmer/.rvm/wrappers/ruby-2.5.5@global/bin:/home/sschirmer/.rvm/rubies/ruby-2.5.5/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/sschirmer/.rvm/bin:/home/sschirmer/.rvm/bin:/home/sschirmer/.rvm/environments/ruby-2.5.5
export GEM_PATH=/home/sschirmer/.rvm/gems/ruby-2.5.5:/home/sschirmer/.rvm/gems/ruby-2.5.5@global
export RUBY_VERSION=ruby-2.5.5
export IRBRC=/home/sschirmer/.rvm/rubies/ruby-2.5.5/.irbrc
export MY_RUBY_HOME=/home/sschirmer/.rvm/wrappers/ruby-2.5.5/ruby
export rvm_bin_path=/home/sschirmer/.rvm/bin



`/home/sschirmer/.rvm/wrappers/ruby-2.5.5/ruby /home/sschirmer/crons/intercom/main.rb >> /home/sschirmer/crons/logs/intercom.txt`
