# rubocop-afcapel

Custom [RuboCop](https://rubocop.org/) cops for personal coding conventions.

## Installation

Add to your `Gemfile`:

```ruby
gem "rubocop-afcapel", github: "afcapel/ruby-style-guide", require: false
```

Then in your `.rubocop.yml`:

```yaml
require:
  - rubocop-afcapel
```

All cops are enabled by default.

## Cops

### `Afcapel/NewspaperMethodOrder`

Methods must be defined after all the methods that call them — high-level intent first, implementation details last.

```ruby
# bad
class Order
  def validate
    check_inventory
  end

  def process
    validate
    charge
  end

  def check_inventory
    # ...
  end

  def charge
    # ...
  end
end

# good
class Order
  def process
    validate
    charge
  end

  def validate
    check_inventory
  end

  def charge
    # ...
  end

  def check_inventory
    # ...
  end
end
```

Circular call chains are skipped. Methods with no internal callers are ignored.

### `Afcapel/NoBangMethodWithoutCounterpart`

A bang method (`def foo!`) requires a non-bang counterpart (`def foo`) in the same file.

```ruby
# bad
def process!
  do_work or raise
end

# good
def process
  do_work
end

def process!
  do_work or raise
end
```

### `Afcapel/NoEarlyReturn`

Guard clauses at the top of a method are fine. All other `return` statements are flagged.

```ruby
# good
def foo
  return if invalid?
  return unless authorized?
  compute_result
end

# bad
def foo
  result = compute
  return result if result.valid?
  default_value
end
```

## Built-in cop overrides

This gem also enables `Layout/ClassStructure` with a standard ordering: includes, constants, associations, macros, class methods, initializer, public methods, protected methods, private methods.

## Development

```bash
bundle install
bundle exec rake test
bundle exec rubocop
```

## License

MIT
