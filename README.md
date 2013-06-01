RubyAppraiser
=============

So you have a big project and you want to improve the code quality? Sweet. Too
bad you'll get a million errors when you run [rubocop][], [reek][], or
[flog][], so it'll annoy you with information overload until you get fed up & 
turn it off.

Enter: RubyAppraiser, a generic interface for attaching code-quality tools
that limits their output to the lines you're changing, which allows you to use
these tools to gradually heal projects. Add a pre-commit hook that rejects
defective contributions, level up to require entire touched files to be fixed,
or run several code-quality tools in a single command.

The filters currently provided are:

 - all - (default) show all defects
 - authored - all uncommitted defects
 - staged - all staged defects
 - touched - all defects in files that have been touched

Usage:
------

1. Include one or more adapters in your `Gemfile` or as development
dependencies of your gem. They'll make sure their dependencies (including
`ruby-appraiser` itself) are taken care of.

```ruby
gem 'ruby-appraiser-rubocop'
gem 'ruby-appraiser-reek'
```

2. Execute the appraiser:

```sh
bundle exec ruby-appraiser --mode=authored reek rubocop
```

The script will exit 0 IFF there are no matching defects from any of your
coverage tools. The tools themselves will respect any project-wide settings or
config files.

```
$ bundle exec ruby-appraiser --help
Usage: ruby-appraiser [inspector...] [options]
    -v, --[no-]verbose        Run verbosely
        --list                List available adapters
        --silent              Silence output
        --mode=MODE           Set the mode. [staged,authored,touched,all]
        --git-hook            Output a git hook with current comand to STDOUT
        --all                 Run all available adapters.
```

Contributing:
-------------

1. Write an adapter! Take a look at the existing adapters for help.

```ruby
class Foo < RubyAppraiser::Adapter
  def appraise
    # ...
    add_defect( file, line, description )
    # ...
  end
end
```

License
-------
See [LICENSE][]

[LICENSE]: LICENSE.md
[rubocop]: https://github.com/bbatslov/rubocop
[reek]: https://github.com/troessner/reek
[flog]: https://github.com/seattlerb/flog
