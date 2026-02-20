# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Flags guard clauses that should be conditional expressions.
      #
      # A single guard followed by a single expression is not a
      # precondition — the conditional *is* the logic. Write it as
      # a conditional expression instead.
      #
      # Two or more guard clauses at the top of a method should be
      # combined or the method should be restructured.
      #
      # @example
      #   # bad — guard before single expression
      #   def weight_change
      #     return nil unless weight_start && weight_end
      #     (weight_end - weight_start).round(1)
      #   end
      #
      #   # good
      #   def weight_change
      #     (weight_end - weight_start).round(1) if weight_start && weight_end
      #   end
      #
      #   # bad — multiple guard clauses
      #   def process(order)
      #     return unless order.valid?
      #     return unless order.paid?
      #     ship(order)
      #   end
      #
      #   # good
      #   def process(order)
      #     ship(order) if order.valid? && order.paid?
      #   end
      class UnnecessaryGuardClause < Base
        SINGLE_EXPRESSION_MSG = "Use a conditional expression instead of a guard clause when the method body is a single expression."
        MULTIPLE_GUARDS_MSG = "Avoid multiple guard clauses. Combine conditions or restructure the method."

        def on_def(node)
          check(node)
        end

        def on_defs(node)
          check(node)
        end

        private

        def check(node)
          body = node.body
          return unless body

          statements = body.begin_type? ? body.children : [ body ]
          guards = leading_guard_clauses(statements)
          return if guards.empty?

          remaining = statements.size - guards.size

          if guards.size == 1 && remaining == 1
            add_offense(guards.first, message: SINGLE_EXPRESSION_MSG)
          elsif guards.size >= 2
            guards.each { |g| add_offense(g, message: MULTIPLE_GUARDS_MSG) }
          end
        end

        def leading_guard_clauses(statements)
          guards = []

          statements.each do |stmt|
            if guard_clause?(stmt)
              guards << stmt
            else
              break
            end
          end

          guards
        end

        def guard_clause?(node)
          case node.type
          when :return
            true
          when :if
            node.modifier_form? && node.if_branch&.return_type?
          else
            false
          end
        end
      end
    end
  end
end
