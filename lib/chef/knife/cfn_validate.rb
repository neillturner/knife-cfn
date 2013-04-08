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
    class CfnValidate < Chef::Knife::CfnBase
    
      deps do
        require 'fog'
        require 'readline'
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      
      banner "knife cfn validate (options)"

      option :template_file,
        :short => "-f TEMPLATE_FILE",
        :long => "--template-file TEMPLATE_FILE",
        :description => "Path to the file that contains the template",
        :proc => Proc.new { |f| Chef::Config[:knife][:template_file] = f }
        
      option :template_url,
        :short => "-u TEMPLATE_URL",
        :long => "--template-file TEMPLATE_URL",
        :description => "Path to the URL that contains the template",
        :proc => Proc.new { |u| Chef::Config[:knife][:template_url] = u }
        

      def run
        $stdout.sync = true

        validate!
        
	begin
           response = connection.validate_template(create_validate_def)
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
           print "\n#{ui.color("Template validated successfully", :green)}"
        end
      end   
        
      def create_validate_def
        validate_def = {} 
        template_file = locate_config_value(:template_file)
        if template_file != nil and template_file != ""
            doc = File.open(template_file, 'rb') { |file| file.read }
	    validate_def['TemplateBody'] = doc
	else    
	    validate_def['TemplateURL'] = locate_config_value(:template_url)
	end
	validate_def
      end
      
    end
  end
end
