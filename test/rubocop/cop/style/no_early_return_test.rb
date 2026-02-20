# frozen_string_literal: true

require "test_helper"

class NoEarlyReturnTest < Minitest::Test
  include CopTestHelper

  def cop
    @cop ||= RuboCop::Cop::Style::NoEarlyReturn.new
  end

  def test_allows_guard_clause_return_if
    assert_no_offenses(<<~RUBY)
      def foo
        return if invalid?
        compute_result
      end
    RUBY
  end

  def test_allows_guard_clause_return_unless
    assert_no_offenses(<<~RUBY)
      def foo
        return unless authorized?
        compute_result
      end
    RUBY
  end

  def test_allows_bare_return_guard
    assert_no_offenses(<<~RUBY)
      def foo
        return
      end
    RUBY
  end

  def test_allows_return_value_guard
    assert_no_offenses(<<~RUBY)
      def foo
        return nil if blank?
        compute_result
      end
    RUBY
  end

  def test_allows_multiple_guard_clauses
    assert_no_offenses(<<~RUBY)
      def foo
        return if invalid?
        return unless authorized?
        return if skip?
        compute_result
      end
    RUBY
  end

  def test_allows_method_without_returns
    assert_no_offenses(<<~RUBY)
      def foo
        compute_result
      end
    RUBY
  end

  def test_allows_empty_method
    assert_no_offenses(<<~RUBY)
      def foo
      end
    RUBY
  end

  def test_flags_return_after_logic
    offenses = assert_offense(<<~RUBY)
      def foo
        result = compute
        return result if result.valid?
        default_value
      end
    RUBY
    assert_equal 3, offenses.first.line
  end

  def test_flags_nested_return
    offenses = assert_offense(<<~RUBY)
      def process(order)
        if order.valid?
          return order
        end
        handle_error
      end
    RUBY
    assert_equal 3, offenses.first.line
  end

  def test_flags_return_in_else_branch
    offenses = assert_offense(<<~RUBY)
      def foo
        if condition
          do_something
        else
          return bar
        end
      end
    RUBY
    assert_equal 5, offenses.first.line
  end

  def test_flags_return_after_guard_clauses
    offenses = assert_offense(<<~RUBY)
      def foo
        return if invalid?
        do_work
        return result
      end
    RUBY
    assert_equal 4, offenses.first.line
  end

  def test_works_with_class_methods
    offenses = assert_offense(<<~RUBY)
      def self.foo
        result = compute
        return result
      end
    RUBY
    assert_equal 3, offenses.first.line
  end

  def test_allows_guard_clause_on_class_methods
    assert_no_offenses(<<~RUBY)
      def self.foo
        return if invalid?
        compute_result
      end
    RUBY
  end
end
