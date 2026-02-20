# frozen_string_literal: true

require "test_helper"

class NewspaperMethodOrderTest < Minitest::Test
  include CopTestHelper

  def cop
    @cop ||= RuboCop::Cop::Afcapel::NewspaperMethodOrder.new
  end

  def test_flags_helper_defined_before_its_only_caller
    offenses = assert_offense(<<~RUBY)
      class Order
        def helper
          compute
        end

        def process
          helper
        end
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_allows_helper_defined_after_its_caller
    assert_no_offenses(<<~RUBY)
      class Order
        def process
          helper
        end

        def helper
          compute
        end
      end
    RUBY
  end

  def test_does_not_flag_methods_with_no_internal_callers
    assert_no_offenses(<<~RUBY)
      class Order
        def process
          external_call
        end

        def other
          something_else
        end
      end
    RUBY
  end

  def test_flags_helper_with_a_caller_after_it
    # helper should be defined after late_caller too
    offenses = assert_offense(<<~RUBY)
      class Order
        def early_caller
          helper
        end

        def helper
          compute
        end

        def late_caller
          helper
        end
      end
    RUBY
    assert_equal 6, offenses.first.line
  end

  def test_allows_helper_defined_after_all_callers
    assert_no_offenses(<<~RUBY)
      class Order
        def early_caller
          helper
        end

        def late_caller
          helper
        end

        def helper
          compute
        end
      end
    RUBY
  end

  def test_does_not_flag_circular_calls
    assert_no_offenses(<<~RUBY)
      class Foo
        def a
          b
        end

        def b
          a
        end
      end
    RUBY
  end

  def test_does_not_flag_indirect_cycle
    assert_no_offenses(<<~RUBY)
      class Foo
        def a
          b
        end

        def b
          c
        end

        def c
          a
        end
      end
    RUBY
  end

  def test_flags_multiple_misordered_methods
    offenses = assert_offense(<<~RUBY, count: 2)
      class Order
        def helper_a
          compute
        end

        def helper_b
          compute
        end

        def process
          helper_a
          helper_b
        end
      end
    RUBY
    assert_equal 2, offenses.first.line
    assert_equal 6, offenses.last.line
  end

  def test_flags_helper_called_by_method_after_it
    # helper_a is called by process (before it) and helper_b (after it).
    # helper_a should appear after helper_b since helper_b calls it.
    offenses = assert_offense(<<~RUBY)
      class Order
        def process
          helper_a
          helper_b
        end

        def helper_a
          compute
        end

        def helper_b
          helper_a
        end
      end
    RUBY
    assert_equal 7, offenses.first.line
  end

  def test_handles_class_methods
    offenses = assert_offense(<<~RUBY)
      class Order
        def self.helper
          compute
        end

        def self.process
          helper
        end
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_handles_modules
    offenses = assert_offense(<<~RUBY)
      module Helpers
        def helper
          compute
        end

        def process
          helper
        end
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_allows_empty_class
    assert_no_offenses(<<~RUBY)
      class Order
      end
    RUBY
  end

  def test_allows_single_method
    assert_no_offenses(<<~RUBY)
      class Order
        def process
          compute
        end
      end
    RUBY
  end

  def test_recursive_method_defined_before_caller_is_flagged
    offenses = assert_offense(<<~RUBY)
      class Foo
        def helper(n)
          helper(n - 1)
        end

        def process
          helper(10)
        end
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_flags_chain_of_misordered_helpers
    offenses = assert_offense(<<~RUBY, count: 2)
      class Order
        def deep_helper
          compute
        end

        def helper
          deep_helper
        end

        def process
          helper
        end
      end
    RUBY
    assert_equal 2, offenses.first.line
    assert_equal 6, offenses.last.line
  end
end
