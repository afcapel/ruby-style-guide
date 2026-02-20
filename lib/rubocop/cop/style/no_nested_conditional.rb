# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Flags conditionals nested inside other conditionals.
      #
      # Nested conditionals add layers of indirection that make
      # the logic harder to follow. Extract a method or use guard
      # clauses to flatten the structure and keep all branches at
      # the same level of abstraction.
      #
      # @example
      #   # bad
      #   def process(order)
      #     if order.valid?
      #       if order.paid?
      #         ship(order)
      #       end
      #     end
      #   end
      #
      #   # good — guard clauses
      #   def process(order)
      #     return unless order.valid?
      #     return unless order.paid?
      #     ship(order)
      #   end
      #
      #   # good — extracted method
      #   def process(order)
      #     if order.valid?
      #       ship_if_paid(order)
      #     end
      #   end
      class NoNestedConditional < Base
        MSG = "Avoid nested conditionals. Extract a method or use guard clauses."

        def on_if(node)
          return if node.ternary?
          return if node.elsif?

          add_offense(node) if nested_in_conditional?(node)
        end

        private

        def nested_in_conditional?(node)
          node.each_ancestor do |ancestor|
            return false if scope_boundary?(ancestor)
            return true if ancestor.if_type? && !ancestor.ternary?
          end

          false
        end

        def scope_boundary?(node)
          node.def_type? || node.defs_type? || node.block_type? ||
            node.numblock_type? || node.lambda_type? ||
            node.class_type? || node.module_type? || node.sclass_type?
        end
      end
    end
  end
end
