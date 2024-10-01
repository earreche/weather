# frozen_string_literal: true

class StatesValue
  attr_reader :state_code

  def initialize(state_code)
    @state_code = state_code
  end

  def cities
    if ENV['USE_CITIES_GEM'] == 'true'
      CS.cities(state_code)
    else
      state_cities_us
    end
  end

  def state_cities_us
    return if state_code.blank?

    ::CITIES[state_code.to_sym]&.uniq
  end
end
