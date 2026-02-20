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
- `lib/rubocop/cop/{layout,naming,style}/` — cop implementations, one file per cop, organized by RuboCop department
- `config/default.yml` — default enabled/disabled state for each cop, plus built-in cop overrides
- `rubocop.yml` — shipped config that inherits `rubocop-rails-omakase` and re-enables all custom cops (omakase blanket-disables departments)
- `test/rubocop/cop/` — tests mirror the cop directory structure

## Adding a new cop

1. Create `lib/rubocop/cop/<department>/<cop_name>.rb` under `RuboCop::Cop::<Department>`
2. Add a `require_relative` in `lib/rubocop-afcapel.rb`
3. Add an entry in `config/default.yml`
4. Re-enable the cop in `rubocop.yml` (needed because omakase disables entire departments)
5. Add tests in `test/rubocop/cop/<department>/<cop_name>_test.rb`

## Testing conventions

- Tests use Minitest with the `CopTestHelper` module from `test/test_helper.rb`
- Each test class defines a `cop` method returning the cop instance
- Use `assert_no_offenses(source)` and `assert_offense(source, count: N)` helpers
- `assert_offense` returns the offenses array for further assertions (e.g. line numbers)

## Cops

### `Layout/NewspaperMethodOrder`

Methods must be defined after all the methods that call them. High-level intent first, implementation details last. Circular call chains are skipped. Methods with no internal callers (public API, callbacks) are ignored.

### `Naming/NoBangMethodWithoutCounterpart`

Flags bang method definitions (`def foo!`) when no non-bang counterpart (`def foo`) exists in the same file. A bang method implies a quieter alternative exists.

### `Style/NoEarlyReturn`

Guard clauses at the top of a method are fine. All other `return` statements are flagged.

A guard clause is a leading `return`, `return value`, `return if cond`, or `return unless cond` in modifier form. Once a non-guard statement is encountered, all subsequent `return` nodes anywhere in the method body are offenses.

### `Style/NoNestedConditional`

Flags `if`/`unless` nested inside another `if`/`unless`. `elsif` chains are not considered nested. Ternaries and conditionals inside blocks are ignored (blocks create a scope boundary).

### `Style/UnnecessaryGuardClause`

Two patterns are flagged:
- **Single guard + single expression**: the guard isn't a precondition, it *is* the logic. Write as a conditional expression.
- **Two or more leading guard clauses**: combine the conditions or restructure the method.

A single guard before multiple statements is allowed — that's a legitimate precondition.

### Built-in cop overrides

- `Layout/ClassStructure` — enabled with default ordering (includes, constants, associations, macros, class methods, instance methods, private methods) and Rails association categories.
