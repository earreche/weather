# frozen_string_literal: true

class HomePage < ApplicationPage
  # Actions
  def visit_home_page
    visit root_path(protocol: :https)
  end

  def fill_location(country, state, city)
    click_button 'Change City'
    select_country(country)
    select_state(state)
    select_city(city)
  end

  def select_country(country)
    page.has_text?('Country', wait: 5)
    select country, from: 'country'
  end

  def select_state(state)
    page.has_text?(state, wait: 5)
    select state, from: 'state'
  end

  def select_city(city)
    page.has_css?(city, wait: 5)
    select city, from: 'city'
  end

  def click_get_weather_for_city
    click_button 'Get weather from this city'
  end

  # Expectations
  def has_refresh_text?
    page.has_text?('Weather should be here, if you are reading this you need to accept ' \
                   'location permissions, click to Show weather from your location or pick a city')
  end

  def has_weather_at_your_location?
    page.has_text?('Current weather at your location', wait: 10)
  end

  def has_weather_at_city?(city, country)
    page.has_text?("Current weather at #{city}, #{country}", wait: 10)
  end

  def has_current_temperature?(temperature)
    page.has_text?("Temperature: #{temperature}", wait: 10)
  end

  def has_country_select?
    page.has_text?('Country')
  end
end
