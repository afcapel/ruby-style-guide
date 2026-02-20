# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/cop/layout/newspaper_method_order"
require_relative "rubocop/cop/naming/no_bang_method_without_counterpart"
require_relative "rubocop/cop/style/no_early_return"
require_relative "rubocop/cop/style/no_nested_conditional"

RuboCop::ConfigLoader.inject_defaults!(File.expand_path("../config/default.yml", __dir__))
