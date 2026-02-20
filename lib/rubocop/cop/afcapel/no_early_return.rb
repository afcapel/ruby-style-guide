# frozen_string_literal: true

module RuboCop
  module Cop
    module Afcapel
      # Disallow early returns in method bodies.
      #
      # Guard clauses at the beginning of a method are allowed.
      # All other `return` statements are flagged.
      #
      # @example
      #   # good - guard clauses
      #   def foo
      #     return if invalid?
      #     return unless authorized?
      #     compute_result
      #   end
      #
      #   # bad - return after logic
      #   def foo
      #     result = compute
      #     return result if result.valid?
      #     default_value
      #   end
      #
      #   # bad - nested return
      #   def process(order)
      #     if order.valid?
      #       return order
      #     end
      #     handle_error
      #   end
      class NoEarlyReturn < Base
        MSG = "Avoid early return. Use guard clauses at the top of the method or restructure the logic."

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

          guard_returns = find_guard_returns(body)

          body.each_descendant(:return) do |return_node|
            next if guard_returns.include?(return_node)

            add_offense(return_node)
          end
        end

        def find_guard_returns(body)
          guards = Set.new
          statements = body.begin_type? ? body.children : [ body ]

          statements.each do |statement|
            if guard_clause?(statement)
              guards << extract_return(statement)
            else
              break
            end
          end

          guards
        end

        def guard_clause?(statement)
          case statement.type
          when :return
            true
          when :if
            return false unless statement.modifier_form?

            body = statement.if_branch
            body&.return_type?
          else
            false
          end
        end

        def extract_return(statement)
          case statement.type
          when :return
            statement
          when :if
            statement.if_branch
          end
        end
      end
    end
  end
end
