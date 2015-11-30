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

require 'chef/knife'
require 'chef/knife/cfn_base'

class Chef
  class Knife
    class CfnCreate < Chef::Knife::CfnBase

      deps do
        require 'fog'
        require 'readline'
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife cfn create <stack name> (options)"

      option :capabilities,
        :short => "-C CAPABILITY..",
        :long => "--capabilities CAPABILITY1,CAPABILITY2,CAPABILITY3..",
        :description => "The explicitly approved capabilities that may be used during this stack creation",
        :proc => Proc.new { |capabilities| capabilities.split(',') }

      option :disable_rollback,
        :short => "-d",
        :long => "--disable-rollback",
        :description => "Flag to disable rollback of created resources when failures are encountered during stack creation. The default value is 'false'",
        :proc => Proc.new { |d| Chef::Config[:knife][:disable_rollback] = "true" }

      option :template_file,
        :short => "-f TEMPLATE_FILE",
        :long => "--template-file TEMPLATE_FILE",
        :description => "Path to the file that contains the template",
        :proc => Proc.new { |f| Chef::Config[:knife][:template_file] = f }

      option :notification_arns,
        :short => "-n NOTIFICATION_ARN1,NOTIFICATION_ARN2,NOTIFICATION_ARN3..",
        :long => "--notification-arns VALUE1,VALUE2,VALUE3..",
        :description => "SNS ARNs to receive notification about the stack",
        :proc => Proc.new { |notification_arns| notification_arns.split(',') }

      option :parameters,
        :short => "-p 'key1=value1;key2=value2...'",
        :long => "--parameters 'key1=value1;key2=value2...'",
        :description => "Parameter values used to create the stack",
        :proc => Proc.new { |parameters| parameters.split(';') }

      option :timeout,
        :short => "-t TIMEOUT_VALUE",
        :long => "--timeout TIMEOUT_VALUE",
        :description => " Stack creation timeout in minutes",
        :proc => Proc.new { |t| Chef::Config[:knife][:timeout] = t }

      option :template_url,
        :short => "-u TEMPLATE_URL",
        :long => "--template-file TEMPLATE_URL",
        :description => "Path of the URL that contains the template. This must be a reference to a template in an S3 bucket in the same region that the stack will be created in",
        :proc => Proc.new { |u| Chef::Config[:knife][:template_url] = u }

      def run
        $stdout.sync = true

        validate!

        stack_name = @name_args[0]

        if stack_name.nil?
          show_usage
          ui.error("You must specify a stack name")
          exit 1
        end

        begin
          response = connection.create_stack(stack_name, create_create_def)
          rescue Excon::Errors::BadRequest => e
            i= e.response.body.index("<Message>")
            j = e.response.body.index("</Message>")
            if !i.nil? and !j.nil?
              ui.error(e.response.body[i+9,j-i-9])
            else
              print "\n#{e.response.body}"
            end
            exit 1
          else
            message = "Stack #{stack_name} creation started"
            print "\n#{ui.color(message, :green)}\n"
          end
        end
      end

      def create_create_def
        create_def = {}
        template_file = locate_config_value(:template_file)
        if template_file != nil and template_file != ""
          doc = File.open(template_file, 'rb') { |file| file.read }
          create_def['TemplateBody'] = doc
        end
        create_def['TemplateURL'] = locate_config_value(:template_url)
        create_def['Capabilities'] = locate_config_value(:capabilities)
        create_def['DisableRollback'] = locate_config_value(:disable_rollback)
        create_def['NotificationARNs'] = locate_config_value(:notification_arns)
        hashed_parameters={}
        parameters = locate_config_value(:parameters)
        parameters.map{ |t| key,val=t.split('='); hashed_parameters[key]=val} unless parameters.nil?
        create_def['Parameters'] = hashed_parameters
        create_def['TimeoutInMinutes'] = locate_config_value(:timeout)
        create_def
      end

  end
end
