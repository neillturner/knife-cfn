$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef'
require 'knife-cnf/cfn_base'
require 'knife-cnf/cfn_create'
require 'knife-cnf/cfn_delete'
require 'knife-cnf/cfn_describe'
require 'knife-cnf/cfn_events'
require 'knife-cnf/cfn_validate'

