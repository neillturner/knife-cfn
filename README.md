Knife CFN
=========

This is a Knife plugin for AWS Cloud Formation. This plugin gives knife the ability to validate, create, describe, and delete stacks.

Installation
------------

Be sure you are running the latest version Chef. Versions earlier than 0.10.0 don't support plugins:

    gem install chef

This plugin is distributed as a Ruby Gem. To install it, run:

    gem install knife-cfn

Depending on your system's configuration, you may need to run this command with root privileges.

Configuration
-------------

In order to communicate with the Amazon's CloudFormation API you will have to tell Knife about your AWS Access Key and Secret Access Key. The easiest way to accomplish this is to create some entries in your `knife.rb` file:

```ruby
knife[:aws_access_key_id] = "Your AWS Access Key ID"
knife[:aws_secret_access_key] = "Your AWS Secret Access Key"
```

If your `knife.rb` file will be checked into a SCM system (ie readable by others) you may want to read the values from environment variables:

```ruby
knife[:aws_access_key_id] = ENV['AWS_ACCESS_KEY_ID']
knife[:aws_secret_access_key] = ENV['AWS_SECRET_ACCESS_KEY']
# Optional if you're using Amazon's STS
knife[:aws_session_token] = ENV['AWS_SESSION_TOKEN']
```

You also have the option of passing your AWS API Key/Secret into the individual knife subcommands using the `-A` (or `--aws-access-key-id`) `-K` (or `--aws-secret-access-key`) command options

```bash
# provision a new stack
$ knife cfn create test -f test.stack
```

If you are working with Amazon's command line tools, there is a good chance
you already have a file with these keys somewhere in this format:

    AWSAccessKeyId=Your AWS Access Key ID
    AWSSecretKey=Your AWS Secret Access Key


The new config file format used by Amazon's command line tools is also supported:

    [default]
    aws_access_key_id = Your AWS Access Key ID
    aws_secret_access_key = Your AWS Secret Access Key

In this case, you can point the <tt>aws_credential_file</tt> option to
this file in your <tt>knife.rb</tt> file, like so:

```ruby
knife[:aws_credential_file] = "/path/to/credentials/file/in/above/format"
```

If you have multiple profiles in your credentials file you can define which
profile to use. The `default` profile will be used if not supplied,

```ruby
knife[:aws_profile] = "personal"
```

Subcommands
-----------

This plugin provides the following Knife subcommands.  Specific command options can be found by invoking the subcommand with a <tt>--help</tt> flag

#### `knife cfn validate`

Validates a template file of template URL.

#### `knife cfn create`

Create a cloud formation stack from a template file or Template URL.

#### `knife cfn update`

Update a cloud formation stack from a template file or Template URL.

#### `knife cfn delete`

Deletes a running cloud formation stack.

#### `knife cfn describe [-l / --long ] [stack name]`

Outputs the name, status, creation time and rollback status of a stack, or all stacks if <tt>stack name</tt> is omitted.
The <tt>--long</tt> (<tt>-l</tt>) parameter shows stack IDs (ARN) instead of friendly names.

#### `knife cfn events [ stack name ]`

Outputs a list of events for a stack name.

#### `knife cfn resources [ stack name ] [ logical resource id ]`

Outputs the logical resource ID, physical resource ID, resource type and status for all resources of a stack. If <tt>logical resource
id</tt> is specified, then only the details of that resource is shown. A logical resource ID is reference given to a resource in the cloudformation
template, under the "Resources" section.

#### `knife cfn outputs [ -o ] [ stack name ]`

Outputs a list of outputs for a stack name. If <tt>-o</tt> option is specified, then output will be formatted in the same syntax as parameters for cfn create / update

License
-------

Author:: Neill Turner (neillwturner@gmail.com)
Copyright:: Copyright (c) 2012 EC2Dream.
License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

