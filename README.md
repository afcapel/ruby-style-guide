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

### `Layout/NewspaperMethodOrder`

Code should read like a newspaper article — headline first, synopsis, then details as you read down. You should be able to read a class from top to bottom and understand the story without jumping around. When a method calls another method, that method should appear below it, creating a natural drill-down from intent to implementation. If you find yourself scrolling up to find where a helper is defined, the code isn't ordered correctly.

This idea comes from Robert C. Martin's *Clean Code* (Chapter 5: Formatting — "The Newspaper Metaphor" and "Vertical Ordering").

```ruby
# bad — forces the reader to jump around
class OrderProcessor
  private

  def check_inventory(order)
    # Why is this first?
  end

  public

  def process(order)
    # Now I have to scroll up to find check_inventory
    validate_order(order)
    charge_customer(order)
    send_confirmation(order)
  end
end

# good — reads top to bottom
class OrderProcessor
  def process(order)
    validate_order(order)
    charge_customer(order)
    send_confirmation(order)
  end

  private

  def validate_order(order)
    check_inventory(order) if order.valid?
  end

  def charge_customer(order)
    # ...
  end

  def send_confirmation(order)
    # ...
  end

  def check_inventory(order)
    # called by validate_order, so it comes after
  end
end
```

### `Naming/NoBangMethodWithoutCounterpart`

In the Ruby standard library, bang methods signal a more dangerous variant of a quieter counterpart: `sort` returns a new array, `sort!` mutates in place; `save` returns false on failure, `save!` raises. The `!` is a contract — it tells the reader "there's a safer alternative."

Defining a bang method without its counterpart breaks that contract. If there's only `process!` and no `process`, the `!` is meaningless noise. Either the method isn't dangerous enough to warrant it, or the non-bang variant is missing.

```ruby
# bad — no `process` defined, the `!` is misleading
def process!
  do_work or raise
end

# good — both variants exist, the `!` signals different behavior
def process
  do_work
end

def process!
  do_work or raise
end
```

### `Style/NoEarlyReturn`

Early returns in the middle of a method obscure the logical flow. When a method has multiple exit points scattered through its body, you have to mentally trace every path to understand what it does. Conditional expressions make all branches explicit and keep them at the same level of abstraction — you can see the full decision tree in one place.

Guard clauses at the top of a method are the exception. They handle preconditions upfront and let the reader focus on the main logic without nesting. Once the guards are done, the rest of the method should flow without surprise exits.

```ruby
# good — guard clauses at the top
def foo
  return if invalid?
  return unless authorized?
  compute_result
end

# bad — return in the middle obscures the flow
def foo
  result = compute
  return result if result.valid?
  default_value
end

# good — explicit branches at the same level of abstraction
def foo
  result = compute
  if result.valid?
    result
  else
    default_value
  end
end
```

## Built-in cop overrides

### `Layout/ClassStructure`

Enforces a consistent class layout: includes, constants, associations, macros, class methods, initializer, public methods, protected methods, private methods. The public interface comes first (what the class does), private helpers go at the bottom.

## Development

```bash
bundle install
bundle exec rake test
bundle exec rubocop
```

## License

MIT
