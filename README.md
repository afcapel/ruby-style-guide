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

Organize code top-to-bottom so it reads like a newspaper — high-level intent first, implementation details last. You should be able to read a class from top to bottom and understand the story without jumping around.

A method should read like a paragraph. When it calls another method, that method should appear below it — creating a natural drill-down from intent to implementation.

This cop flags a method when any of its callers (within the same class or module) appears after it. The method should be defined after all of its callers.

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

The payoff is faster comprehension and less cognitive load. If you find yourself scrolling up to find where a helper is defined, the code isn't ordered correctly.

Circular call chains are skipped. Methods with no internal callers (public API entry points, callbacks, etc.) are ignored.

### `Naming/NoBangMethodWithoutCounterpart`

Only add bang methods (ending in `!`) when there's a non-bang alternative with different behavior. A bang method implies a non-bang alternative exists — `save!` makes sense because `save` exists with different behavior (returns false vs raises). Defining `process!` when there's no `process` counterpart is misleading.

This cop flags bang method definitions (`def foo!`) when no non-bang counterpart (`def foo`) exists in the same file.

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

Early returns work well as guard clauses at the beginning of methods. In method bodies, prefer conditional expressions for clarity. This cop allows guard clauses at the top of a method and flags all other `return` statements.

A guard clause is a leading `return`, `return value`, `return if cond`, or `return unless cond` in modifier form. Once a non-guard statement is encountered, all subsequent `return` nodes anywhere in the method body are offenses.

```ruby
# good — guard clauses at the top
def foo
  return if invalid?
  return unless authorized?
  compute_result
end

# bad — return after logic
def foo
  result = compute
  return result if result.valid?
  default_value
end

# good — use a conditional expression instead
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

Enabled with a standard ordering that enforces consistent class layout: includes, constants, associations, macros, class methods, initializer, public methods, protected methods, private methods. This ensures the public interface comes first (what the class does) with private helpers at the bottom.

## Development

```bash
bundle install
bundle exec rake test
bundle exec rubocop
```

## License

MIT
