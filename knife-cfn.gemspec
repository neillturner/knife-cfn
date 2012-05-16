# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "knife-cfn"
  s.version = "0.1.1"
  s.summary = "CloudFormation Support for Knife"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.author = "Neill Turner"
  s.description = "CloudFormation Support for Chef's Knife Command"
  s.email = "neillwturner@gmail.com"
  s.homepage = 'https://github.com/neillturner/knife-cfn'
  s.files = Dir["lib/**/*"]
  s.rubygems_version = "1.6.2"
  s.add_dependency "fog", "~> 1.3"
  s.add_dependency "chef", "~> 0.10"
end
