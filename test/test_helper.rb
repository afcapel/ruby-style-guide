# frozen_string_literal: true

require "minitest/autorun"
require "rubocop"
require "rubocop-afcapel"

module CopTestHelper
  def investigate(source)
    processed_source = RuboCop::ProcessedSource.new(source, RUBY_VERSION.to_f, nil, parser_engine: :parser_prism)
    config = RuboCop::Config.new({}, "#{Dir.pwd}/.rubocop.yml")
    processed_source.config = config
    processed_source.registry = RuboCop::Cop::Registry.new([ cop.class ])

    team = RuboCop::Cop::Team.new([ cop ], config, raise_error: true)
    report = team.investigate(processed_source)
    report.offenses.reject(&:disabled?)
  end

  def assert_no_offenses(source)
    offenses = investigate(source)
    assert_empty offenses, "Expected no offenses but got:\n#{offenses.map(&:message).join("\n")}"
  end

  def assert_offense(source, count: 1)
    offenses = investigate(source)
    assert_equal count, offenses.size,
      "Expected #{count} offense(s) but got #{offenses.size}:\n#{offenses.map(&:message).join("\n")}"
    offenses
  end
end
