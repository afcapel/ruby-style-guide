# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # Flags bang method definitions (`def foo!`) when no non-bang
      # counterpart (`def foo`) exists in the same file.
      #
      # A bang method implies there is a quieter alternative. Defining
      # one without the counterpart is misleading.
      #
      # @example
      #   # bad — no `process` defined in the file
      #   def process!
      #     do_work
      #   end
      #
      #   # good — both variants exist
      #   def process
      #     do_work
      #   end
      #
      #   def process!
      #     do_work or raise
      #   end
      class NoBangMethodWithoutCounterpart < Base
        MSG = "Do not define a bang method (`%<name>s`) without a non-bang counterpart."

        def on_new_investigation
          @method_names = Set.new
          @bang_methods = []
        end

        def on_def(node)
          track_method(node)
        end

        def on_defs(node)
          track_method(node)
        end

        def on_investigation_end
          @bang_methods.each do |node|
            non_bang_name = node.method_name.to_s.chomp("!").to_sym

            unless @method_names.include?(non_bang_name)
              add_offense(node, message: format(MSG, name: node.method_name))
            end
          end
        end

        private

        def track_method(node)
          name = node.method_name
          @method_names << name
          @bang_methods << node if name.to_s.end_with?("!")
        end
      end
    end
  end
end
