# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Flags a guard clause followed by a single expression.
      #
      # When the entire method body is just a guard that returns nil
      # and one expression, the guard is not a precondition — it *is*
      # the logic. Write it as a conditional expression instead.
      #
      # @example
      #   # bad
      #   def weight_change
      #     return nil unless weight_start && weight_end
      #     (weight_end - weight_start).round(1)
      #   end
      #
      #   # good
      #   def weight_change
      #     (weight_end - weight_start).round(1) if weight_start && weight_end
      #   end
      class UnnecessaryGuardClause < Base
        MSG = "Use a conditional expression instead of a guard clause when the method body is a single expression."

        def on_def(node)
          check(node)
        end

        def on_defs(node)
          check(node)
        end

        private

        def check(node)
          body = node.body
          return unless body&.begin_type?

          statements = body.children
          return unless statements.size == 2

          guard = statements.first
          return unless nil_guard_clause?(guard)

          add_offense(guard)
        end

        def nil_guard_clause?(node)
          case node.type
          when :return
            returns_nil?(node)
          when :if
            node.modifier_form? && nil_return_branch?(node)
          else
            false
          end
        end

        def nil_return_branch?(if_node)
          ret = if_node.if_branch
          ret&.return_type? && returns_nil?(ret)
        end

        def returns_nil?(return_node)
          return_node.arguments.empty? ||
            (return_node.arguments.size == 1 && return_node.first_argument.nil_type?)
        end
      end
    end
  end
end
