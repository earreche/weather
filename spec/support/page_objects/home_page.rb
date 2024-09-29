# frozen_string_literal: true

class HomePage < ApplicationPage
  # Actions
  def visit_home_page
    visit root_path(protocol: :https)
  end

  def fill_location(country, city, state)
    select_country(country)
    select_state(state)
    select_city(city)
  end

  def select_country(country)
    select country, from: 'country'
  end

  def select_state(state)
    page.has_css?('#state', wait: 5)
    select state, from: 'state'
  end

  def select_city(city)
    page.has_css?('#city', wait: 5)
    select city, from: 'city'
  end

  def click_get_weather_for_city
    click_on 'Get weather from this city'
  end

  # Expectations
  def has_refresh_button?
    page.has_button?(text: 'Refresh')
  end

  def has_weather?(weather)
    within '#current-response' do
      page.has_text?(weather, wait: 10)
    end
  end

  def has_city_weather?(weather)
    within '#city-response' do
      page.has_text?(weather, wait: 10)
    end
  end
end
