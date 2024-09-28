# frozen_string_literal: true

class ApplicationPage
  require 'support/turbo_helper'

  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include ::TurboHelper

  attr_reader :object, :options

  def initialize(object = nil, options = {})
    @object = object
    @options = options
  end
end
