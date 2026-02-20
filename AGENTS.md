# rubocop-afcapel

Custom RuboCop cops for personal coding conventions. Reusable gem added to any Ruby project.

## Stack

- Ruby (>= 3.1)
- RuboCop (>= 1.0)
- Minitest for tests
- Style: inherits `rubocop-rails-omakase`

## Commands

```bash
bundle exec rake test    # run tests
bundle exec rubocop      # lint
```

## Architecture

- `lib/rubocop-afcapel.rb` — entry point; requires cops and injects `config/default.yml` into RuboCop defaults
- `lib/rubocop/cop/afcapel/` — cop implementations, one file per cop
- `config/default.yml` — default enabled/disabled state for each cop, plus built-in cop overrides
- `test/rubocop/cop/afcapel/` — tests mirror the cop directory structure

## Adding a new cop

1. Create `lib/rubocop/cop/afcapel/<cop_name>.rb` under `RuboCop::Cop::Afcapel`
2. Add a `require_relative` in `lib/rubocop-afcapel.rb`
3. Add an entry in `config/default.yml`
4. Add tests in `test/rubocop/cop/afcapel/<cop_name>_test.rb`

## Testing conventions

- Tests use Minitest with the `CopTestHelper` module from `test/test_helper.rb`
- Each test class defines a `cop` method returning the cop instance
- Use `assert_no_offenses(source)` and `assert_offense(source, count: N)` helpers
- `assert_offense` returns the offenses array for further assertions (e.g. line numbers)

## Cops

### `Afcapel/NewspaperMethodOrder`

Methods must be defined after all the methods that call them. High-level intent first, implementation details last. Circular call chains are skipped. Methods with no internal callers (public API, callbacks) are ignored.

### `Afcapel/NoBangMethodWithoutCounterpart`

Flags bang method definitions (`def foo!`) when no non-bang counterpart (`def foo`) exists in the same file. A bang method implies a quieter alternative exists.

### `Afcapel/NoEarlyReturn`

Guard clauses at the top of a method are fine. All other `return` statements are flagged.

A guard clause is a leading `return`, `return value`, `return if cond`, or `return unless cond` in modifier form. Once a non-guard statement is encountered, all subsequent `return` nodes anywhere in the method body are offenses.

### Built-in cop overrides

- `Layout/ClassStructure` — enabled with default ordering (includes, constants, associations, macros, class methods, instance methods, private methods) and Rails association categories.
