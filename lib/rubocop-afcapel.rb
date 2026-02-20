# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/cop/afcapel/newspaper_method_order"
require_relative "rubocop/cop/afcapel/no_bang_method_without_counterpart"
require_relative "rubocop/cop/afcapel/no_early_return"

RuboCop::ConfigLoader.inject_defaults!(File.expand_path("../config/default.yml", __dir__))
