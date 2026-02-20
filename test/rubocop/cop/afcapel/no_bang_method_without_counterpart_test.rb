# frozen_string_literal: true

require "test_helper"

class NoBangMethodWithoutCounterpartTest < Minitest::Test
  include CopTestHelper

  def cop
    @cop ||= RuboCop::Cop::Afcapel::NoBangMethodWithoutCounterpart.new
  end

  def test_flags_bang_method_without_counterpart
    offenses = assert_offense(<<~RUBY)
      class Order
        def process!
          do_work
        end
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_allows_bang_method_with_counterpart
    assert_no_offenses(<<~RUBY)
      class Order
        def process
          do_work
        end

        def process!
          do_work or raise
        end
      end
    RUBY
  end

  def test_flags_class_method_bang_without_counterpart
    offenses = assert_offense(<<~RUBY)
      class Order
        def self.create!
          new.tap(&:save)
        end
      end
    RUBY
    assert_equal 2, offenses.first.line
  end

  def test_allows_class_method_bang_with_instance_counterpart
    assert_no_offenses(<<~RUBY)
      class Order
        def create
          save
        end

        def self.create!
          new.tap(&:save)
        end
      end
    RUBY
  end

  def test_allows_methods_without_bang
    assert_no_offenses(<<~RUBY)
      class Order
        def process
          do_work
        end

        def valid?
          errors.empty?
        end
      end
    RUBY
  end

  def test_flags_multiple_bang_methods_without_counterparts
    offenses = assert_offense(<<~RUBY, count: 2)
      class Order
        def process!
          do_work
        end

        def save!
          persist
        end
      end
    RUBY
    assert_equal 2, offenses.first.line
    assert_equal 6, offenses.last.line
  end

  def test_flags_only_bang_methods_missing_counterpart
    offenses = assert_offense(<<~RUBY)
      class Order
        def process
          do_work
        end

        def process!
          do_work or raise
        end

        def save!
          persist
        end
      end
    RUBY
    assert_equal 10, offenses.first.line
  end

  def test_allows_empty_class
    assert_no_offenses(<<~RUBY)
      class Order
      end
    RUBY
  end

  def test_works_with_top_level_methods
    offenses = assert_offense(<<~RUBY)
      def process!
        do_work
      end
    RUBY
    assert_equal 1, offenses.first.line
  end

  def test_allows_top_level_bang_with_counterpart
    assert_no_offenses(<<~RUBY)
      def process
        do_work
      end

      def process!
        do_work or raise
      end
    RUBY
  end
end
