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

      banner "knife cfn describe <stack name>"

      def run
        $stdout.sync = true

        validate!
        
        stack_name = @name_args[0]
		
	if stack_name.nil?
	  show_usage
	  ui.error("You must specify a stack name")
          exit 1
	end

        stack_list = [
          ui.color('Stack ID', :bold),
          ui.color('Status', :bold),
          ui.color('Creation Time', :bold),
          ui.color('Disable Rollback', :bold)
        ]
        
        @name_args.each do |stack_name|
          options = {}
          data = Array.new
	  options['StackName'] = stack_name
          begin
            response = connection.describe_stacks(options)
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
                stack_list << stack['StackId']
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
  #end
end


