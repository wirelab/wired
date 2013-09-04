# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'wired/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'wired'
  s.version     = Wired::VERSION
  s.date        = Date.today.strftime('%Y-%m-%d')
  s.summary     = 'Wirelab Generator'
  s.description = 'The Wirelab application generator'
  s.authors     = ['Wirelab Creative']
  s.email       = 'bart@wirelab.nl'
  s.homepage    = 'https://github.com/wirelab/wired'
  s.files = `git ls-files`.split("\n").
    reject { |file| file =~ /^\./ }.
    reject { |file| file =~ /^(rdoc|pkg)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.license = 'MIT'

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_dependency 'rails', '4.0.0'
  s.add_dependency 'bundler', '>= 1.1'
  s.add_dependency 'hub', '~> 1.10.5'
end