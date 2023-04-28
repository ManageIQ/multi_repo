# MultiRepo

MultiRepo is a tool for managing multiple git repositories.

[![Gem Version](https://badge.fury.io/rb/multi_repo.svg)](http://badge.fury.io/rb/multi_repo)
[![CI](https://github.com/ManageIQ/multi_repo/actions/workflows/ci.yaml/badge.svg)](https://github.com/ManageIQ/multi_repo/actions/workflows/ci.yaml)
[![Code Climate](https://codeclimate.com/github/ManageIQ/multi_repo.svg)](https://codeclimate.com/github/ManageIQ/multi_repo)

## Installation

```sh
gem install multi_repo
```

## Configuration

## Usage

Typical usage will be from single scripts. In order to keep each script manageable, it can be preferable to use bundler/inline to define the gems needed by that script. To do this, add the following to the top of the script:

```ruby
#/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli"
end
```

Then, you would set up options for your script. A `MultiRepo::CLI` helper is provided to make this easier. It has the [optimist](https://github.com/ManageIQ/optimist) gem already prepared and comes with a `.common_options` helper method to set up options for `--repo-set`, `--repo`, and `--dry-run`. For example,

```ruby
opts = Optimist.options do
  opt :some_opt, "An option your script needs", :type => :string, :required => true

  MultiRepo::CLI.common_options(self)
end
```

would produce the following help output:

```
Options:
  -o, --some-opt=<s>    An option your script needs

Common Options:
  -s, --repo-set=<s>    The repo set to work with (default: master)
  -r, --repo=<s+>       Individual repo(s) to work with; Overrides --repo-set
  -d, --dry-run         Execute without making changes
  -h, --help            Show this message
```

After you have set up the options, you can write your script. `MultiRepo::Service` classes are provided to help interface with common third-party services, such as GitHub. `MultiRepo::Helper` classes are provided to do relatively common operations, such as renaming labels. The `MultiRepo::CLI` class also has helpers for looping over the repo set.  For example, to loop over each repo in the repo set and show the file contents one can do:

```ruby
MultiRepo::CLI.each_repo(**opts) do |repo|
  system("ls")
end
```

## GitHub interactions

Certain commands interact with GitHub and expect a GitHub API Token set in the
ENV variable GITHUB_API_TOKEN.

If you don't already have a token, or want to create one specific to these
purposes
- Go to https://github.com/settings/tokens
- Choose "Generate New Token"
- Give the token a description
- At a mimimum, choose "repo" for the permissions.
- Click "Generate Token"
- Copy the token given to you, and keep it in a safe location, as once you leave
  the page, the token is no longer accessible

Then, in order to use it, export the ENV variable permanently, or pass it to the
program as part of the call.

```sh
GITHUB_API_TOKEN=<token> bin/update_labels
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ManageIQ/multi_repo.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
