# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that methods are defined after the methods that call them,
      # following the "newspaper" order: high-level intent first,
      # implementation details last.
      #
      # A method is flagged when any internal caller in the same
      # class/module appears *after* it. The method should be defined
      # after all of its callers.
      #
      # Methods with no internal callers (public API, callbacks, etc.)
      # are ignored. Circular call chains are also ignored.
      #
      # @example
      #   # bad — helper defined before its only caller
      #   class Order
      #     def helper
      #       compute
      #     end
      #
      #     def process
      #       helper
      #     end
      #   end
      #
      #   # good — caller first, helper after
      #   class Order
      #     def process
      #       helper
      #     end
      #
      #     private
      #       def helper
      #         compute
      #       end
      #   end
      class NewspaperMethodOrder < Base
        MSG = "Define `%<name>s` after the methods that call it, not before."

        def on_class(node)
          check_method_order(node.body)
        end

        def on_module(node)
          check_method_order(node.body)
        end

        def on_sclass(node)
          check_method_order(node.body)
        end

        private

        def check_method_order(body)
          return unless body

          methods = collect_direct_methods(body)
          return if methods.size < 2

          method_names = methods.map(&:method_name).to_set

          method_indices = {}
          methods.each_with_index { |m, i| method_indices[m.method_name] = i }

          calls = {}
          methods.each do |m|
            calls[m.method_name] = find_calls(m, method_names)
          end

          callers_of = Hash.new { |h, k| h[k] = [] }
          calls.each do |caller_name, callees|
            callees.each { |callee| callers_of[callee] << caller_name }
          end

          methods.each do |m|
            name = m.method_name
            internal_callers = callers_of[name]
            next if internal_callers.empty?

            my_index = method_indices[name]
            next unless internal_callers.any? { |c| method_indices[c] > my_index }
            next if cycle?(name, calls)

            add_offense(m, message: format(MSG, name: name))
          end
        end

        def collect_direct_methods(body)
          statements = body.begin_type? ? body.children : [ body ]
          statements.select { |s| s.is_a?(RuboCop::AST::Node) && (s.def_type? || s.defs_type?) }
        end

        def find_calls(method_node, method_names)
          calls = Set.new
          return calls unless method_node.body

          method_node.body.each_node(:send) do |send_node|
            next unless send_node.receiver.nil?

            name = send_node.method_name
            calls << name if method_names.include?(name) && name != method_node.method_name
          end

          calls
        end

        def cycle?(method_name, calls)
          visited = Set.new
          stack = (calls[method_name] || Set.new).to_a

          while stack.any?
            current = stack.pop
            next if visited.include?(current)
            return true if current == method_name

            visited << current
            stack.concat((calls[current] || Set.new).to_a)
          end

          false
        end
      end
    end
  end
end
