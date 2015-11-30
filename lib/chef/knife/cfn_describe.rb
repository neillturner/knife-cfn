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
    class CfnDescribe < Chef::Knife::CfnBase

      deps do
        require 'fog'
        require 'readline'
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife cfn describe [stack name] - lists all stacks if [stack name] is omitted."

      option :long_names,
             :short  => "-l",
             :long   => "--long",
             :description  => "Use long stack names (ARN) instead of friendly names"

      option :aws_credential_file,
        :long => "--aws-credential-file FILE",
        :description => "File containing AWS credentials as used by aws cmdline tools",
        :proc => Proc.new { |key| Chef::Config[:knife][:aws_credential_file] = key }

      option :aws_profile,
        :long => "--aws-profile PROFILE",
        :description => "AWS profile, from credential file, to use",
        :default => 'default',
        :proc => Proc.new { |key| Chef::Config[:knife][:aws_profile] = key }

      option :aws_access_key_id,
        :short => "-A ID",
        :long => "--aws-access-key-id KEY",
        :description => "Your AWS Access Key ID",
        :proc => Proc.new { |key| Chef::Config[:knife][:aws_access_key_id] = key }

      option :aws_secret_access_key,
        :short => "-K SECRET",
        :long => "--aws-secret-access-key SECRET",
        :description => "Your AWS API Secret Access Key",
        :proc => Proc.new { |key| Chef::Config[:knife][:aws_secret_access_key] = key }

      option :aws_session_token,
        :long => "--aws-session-token TOKEN",
        :description => "Your AWS Session Token, for use with AWS STS Federation or Session Tokens",
        :proc => Proc.new { |key| Chef::Config[:knife][:aws_session_token] = key }

      option :region,
        :long => "--region REGION",
        :description => "Your AWS region",
        :proc => Proc.new { |key| Chef::Config[:knife][:region] = key }

      option :use_iam_profile,
        :long => "--use-iam-profile",
        :description => "Use IAM profile assigned to current machine",
        :boolean => true,
        :default => false,
        :proc => Proc.new { |key| Chef::Config[:knife][:use_iam_profile] = key }

      def run
        $stdout.sync = true

        validate!

        stack_name = @name_args[0]
        if stack_name.nil?
          @name_args[0] = "__ALL__"
        end

        output_mode = "StackName"
        output_header = "Stack Name"

        if !config[:long_names].nil?
          output_mode = "StackId"
          output_header = "Stack ID"
        end

        stack_list = [
            ui.color(output_header, :bold),
            ui.color('Status', :bold),
            ui.color('Creation Time', :bold),
            ui.color('Disable Rollback', :bold)
        ]

        @name_args.each do |stack_name|
          options = {}
          data = Array.new
          options['StackName'] = stack_name

          begin
            if stack_name == "__ALL__"
              response = connection.describe_stacks()
            else
              response = connection.describe_stacks(options)
            end

            data = response.body['Stacks']
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
            data.each do |stack|
              stack_list << stack[output_mode]
              stack_list << stack['StackStatus']
              stack_list << stack['CreationTime'].to_s
              stack_list << stack['DisableRollback'].to_s
            end

            puts ui.list(stack_list, :uneven_columns_across, 4)
          end
        end
      end
    end
  end
end
