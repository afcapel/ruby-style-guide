# Ruby Style Guide

[RuboCop](https://rubocop.org/) extension that builds on top of [rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase) with additional cops for code structure and readability.

These rules are particularly useful as guardrails for coding agents (Copilot, Claude Code, Cursor, etc.), which tend to define helpers before their callers, sprinkle early returns through method bodies, and add unnecessary bang methods. Static analysis catches these patterns automatically during CI, so you don't have to flag them in review.

## Installation

Add to your `Gemfile`:

```ruby
gem "rubocop-afcapel", github: "afcapel/rubocop-rules", require: false
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
# bad — helpers defined before the method that calls them
class OrderProcessor
  def validate_order(order)
    check_inventory(order) if order.valid?
  end

  def charge_customer(order)
    # ...
  end

  def process(order)
    validate_order(order)
    charge_customer(order)
  end
end

# good — caller first, helpers after
class OrderProcessor
  def process(order)
    validate_order(order)
    charge_customer(order)
  end

  def validate_order(order)
    check_inventory(order) if order.valid?
  end

  def charge_customer(order)
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

### `Style/NoNestedConditional`

Nested conditionals add layers of indirection that make the logic harder to follow. Each level of nesting forces the reader to keep track of more context. When branches are nested, they operate at different levels of abstraction — the outer branch sets up a context that the inner branch refines, which makes it hard to see the full decision tree at a glance.

Break down the method so that both branches of a conditional are at the same level of abstraction. Combine conditions, extract methods, or restructure the logic.

```ruby
# bad — nested conditionals at different abstraction levels
def process(order)
  if order.valid?
    if order.paid?
      ship(order)
    end
  end
end

# good — combine the conditions
def process(order)
  ship(order) if order.valid? && order.paid?
end

# good — extracted method keeps branches at the same level
def process(order)
  if order.valid?
    ship_if_paid(order)
  else
    handle_invalid(order)
  end
end
```

`elsif` chains are not considered nested. Ternaries and conditionals inside blocks are ignored.

### `Style/UnnecessaryGuardClause`

When a method body is just a guard clause followed by a single expression, the guard is not a precondition — it *is* the logic. The conditional is the essence of the method, and a guard clause adds ceremony without clarity. Write it as a conditional expression instead.

```ruby
# bad — the guard is the whole method
def weight_change
  return nil unless weight_start && weight_end
  (weight_end - weight_start).round(1)
end

# good — conditional expression, clear and direct
def weight_change
  (weight_end - weight_start).round(1) if weight_start && weight_end
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
