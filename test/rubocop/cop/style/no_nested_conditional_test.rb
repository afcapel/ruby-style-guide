# frozen_string_literal: true

require "test_helper"

class NoNestedConditionalTest < Minitest::Test
  include CopTestHelper

  def cop
    @cop ||= RuboCop::Cop::Style::NoNestedConditional.new
  end

  def test_flags_if_inside_if
    offenses = assert_offense(<<~RUBY)
      def process(order)
        if order.valid?
          if order.paid?
            ship(order)
          end
        end
      end
    RUBY
    assert_equal 3, offenses.first.line
  end

  def test_flags_unless_inside_if
    offenses = assert_offense(<<~RUBY)
      def process(order)
        if order.valid?
          unless order.cancelled?
            ship(order)
          end
        end
      end
    RUBY
    assert_equal 3, offenses.first.line
  end

  def test_flags_if_inside_unless
    offenses = assert_offense(<<~RUBY)
      def process(order)
        unless order.cancelled?
          if order.paid?
            ship(order)
          end
        end
      end
    RUBY
    assert_equal 3, offenses.first.line
  end

  def test_flags_modifier_if_inside_if
    offenses = assert_offense(<<~RUBY)
      def process(order)
        if order.valid?
          ship(order) if order.paid?
        end
      end
    RUBY
    assert_equal 3, offenses.first.line
  end

  def test_flags_if_inside_else_branch
    offenses = assert_offense(<<~RUBY)
      def process(order)
        if order.valid?
          ship(order)
        else
          if order.retryable?
            retry_order(order)
          end
        end
      end
    RUBY
    assert_equal 5, offenses.first.line
  end

  def test_flags_if_inside_elsif_branch
    offenses = assert_offense(<<~RUBY)
      def process(order)
        if order.shipped?
          track(order)
        elsif order.valid?
          if order.paid?
            ship(order)
          end
        end
      end
    RUBY
    assert_equal 5, offenses.first.line
  end

  def test_does_not_flag_elsif_chain
    assert_no_offenses(<<~RUBY)
      def process(order)
        if order.shipped?
          track(order)
        elsif order.valid?
          ship(order)
        else
          hold(order)
        end
      end
    RUBY
  end

  def test_does_not_flag_flat_conditionals
    assert_no_offenses(<<~RUBY)
      def process(order)
        if order.valid?
          ship(order)
        end
      end
    RUBY
  end

  def test_does_not_flag_sequential_conditionals
    assert_no_offenses(<<~RUBY)
      def process(order)
        if order.valid?
          validate(order)
        end

        if order.paid?
          ship(order)
        end
      end
    RUBY
  end

  def test_does_not_flag_if_inside_block
    assert_no_offenses(<<~RUBY)
      def process(orders)
        if orders.any?
          orders.each do |order|
            if order.valid?
              ship(order)
            end
          end
        end
      end
    RUBY
  end

  def test_does_not_flag_if_inside_nested_method
    assert_no_offenses(<<~RUBY)
      def process(order)
        if order.valid?
          define_method(:ship) do
            if order.paid?
              send_shipment
            end
          end
        end
      end
    RUBY
  end

  def test_does_not_flag_ternary_inside_if
    assert_no_offenses(<<~RUBY)
      def process(order)
        if order.valid?
          order.paid? ? ship(order) : hold(order)
        end
      end
    RUBY
  end

  def test_does_not_flag_if_inside_ternary
    assert_no_offenses(<<~RUBY)
      def status(order)
        order.valid? ? (if order.paid? then "ready" end) : "invalid"
      end
    RUBY
  end

  def test_flags_deeply_nested
    offenses = assert_offense(<<~RUBY, count: 2)
      def process(order)
        if order.valid?
          if order.paid?
            if order.in_stock?
              ship(order)
            end
          end
        end
      end
    RUBY
    assert_equal 3, offenses.first.line
    assert_equal 4, offenses.last.line
  end
end
