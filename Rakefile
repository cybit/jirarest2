# -*- ruby -*-

require 'rubygems'
require 'hoe'

# Hoe.plugin :compiler
# Hoe.plugin :cucumberfeatures
 Hoe.plugin :doofus
# Hoe.plugin :gem_prelude_sucks
 Hoe.plugin :gemspec
 Hoe.plugin :git
# Hoe.plugin :inline
# Hoe.plugin :manifest
# Hoe.plugin :newgem
# Hoe.plugin :racc
# Hoe.plugin :rcov
# Hoe.plugin :rubyforge
# Hoe.plugin :rubygems
# Hoe.plugin :website
 Hoe.plugin :yard

Hoe.spec 'jirarest2' do
  developer('Cyril Bitterich', 'cebit-jirarest@gunnet.de')

  extra_deps << ['json', ">= 1.6.0"]
  extra_deps << ['highline', ">= 1.1.0"]
  extra_dev_deps << ['webmock', ">= 1.7.0"]

#  self.yard_title = 'Jirarest2'
#  self.yard_markup = :markdown
  self.yard_opts = ['--protected'] # any additional YARD options

  # self.rubyforge_name = 'jirarest2x' # if different than 'jirarest2'
end

# vim: syntax=ruby
