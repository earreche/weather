# frozen_string_literal: true

class HomePage < ApplicationPage
  def visit_home_page
    visit root_path(protocol: :https)
  end

  # Expectations
  def has_refresh_button?
    page.has_button?(text: 'Refresh')
  end

  def has_weather?(weather)
    page.has_text?(weather, wait: 10)
  end
end
