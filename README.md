RubyAppraiser
=============

RubyAppraiser is a generic interface for attaching code-quality tools to your development process, limiting the output of those various code-quality tools to only the code that you have recently changed, and allowing multiple code-coverage tools to report at once. The goal is to be able to add a code-quality tool (rubocop, reek) to a project and ensure that no new errors are committed.

The filters currently provided are:

 - all - (default) show all defects
 - authored - all uncommitted defects
 - staged - all staged defects
 - touched - all defects in files that have been touched

Usage:
------

1. Include one or more adapters in your `Gemfile`

```ruby
gem 'ruby-appraiser-rubocop'
gem 'ruby-appraiser-reek'
```

2. Execute the appraiser:

```sh
bundle exec ruby-appraiser --authored reek rubocop
```

The script will exit 0 IFF there are no matching defects from any of your coverage tools. The tools themselves will respect any project-wide settings or config files.

Adapters:
---------


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
