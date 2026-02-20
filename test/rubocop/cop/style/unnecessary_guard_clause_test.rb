# frozen_string_literal: true

require "test_helper"

class UnnecessaryGuardClauseTest < Minitest::Test
  include CopTestHelper

  def cop
    @cop ||= RuboCop::Cop::Style::UnnecessaryGuardClause.new
  end

  def test_flags_return_nil_unless_followed_by_single_expression
    offenses = assert_offense(<<~RUBY)
      def weight_change
        return nil unless weight_start && weight_end
        (weight_end - weight_start).round(1)
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_flags_return_unless_followed_by_single_expression
    offenses = assert_offense(<<~RUBY)
      def foo
        return unless condition
        compute
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_flags_return_if_not_followed_by_single_expression
    offenses = assert_offense(<<~RUBY)
      def foo
        return if invalid?
        compute
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_flags_return_nil_if_followed_by_single_expression
    offenses = assert_offense(<<~RUBY)
      def foo
        return nil if invalid?
        compute
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_allows_guard_before_multiple_statements
    assert_no_offenses(<<~RUBY)
      def process(order)
        return unless order.valid?
        charge(order)
        ship(order)
      end
    RUBY
  end

  def test_allows_guard_returning_non_nil_value
    assert_no_offenses(<<~RUBY)
      def foo
        return :error unless valid?
        compute
      end
    RUBY
  end

  def test_allows_conditional_expression
    assert_no_offenses(<<~RUBY)
      def weight_change
        (weight_end - weight_start).round(1) if weight_start && weight_end
      end
    RUBY
  end

  def test_allows_method_with_only_guard
    assert_no_offenses(<<~RUBY)
      def foo
        return unless condition
      end
    RUBY
  end

  def test_allows_multiple_guards_before_expression
    assert_no_offenses(<<~RUBY)
      def foo
        return unless a
        return unless b
        compute
      end
    RUBY
  end

  def test_works_with_class_methods
    offenses = assert_offense(<<~RUBY)
      def self.foo
        return unless condition
        compute
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_allows_empty_method
    assert_no_offenses(<<~RUBY)
      def foo
      end
    RUBY
  end

  def test_allows_single_expression_method
    assert_no_offenses(<<~RUBY)
      def foo
        compute
      end
    RUBY
  end
end
