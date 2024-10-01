# frozen_string_literal: true

class CountriesValue
  US_STATES = { :AK => 'Alaska',
                :AL => 'Alabama',
                :AR => 'Arkansas',
                :AZ => 'Arizona',
                :CA => 'California',
                :CO => 'Colorado',
                :CT => 'Connecticut',
                :DC => 'District of Columbia',
                :DE => 'Delaware',
                :FL => 'Florida',
                :GA => 'Georgia',
                :HI => 'Hawaii',
                :IA => 'Iowa',
                :ID => 'Idaho',
                :IL => 'Illinois',
                :IN => 'Indiana',
                :KS => 'Kansas',
                :KY => 'Kentucky',
                :LA => 'Louisiana',
                :MA => 'Massachusetts',
                :MD => 'Maryland',
                :ME => 'Maine',
                :MI => 'Michigan',
                :MN => 'Minnesota',
                :MO => 'Missouri',
                :MS => 'Mississippi',
                :MT => 'Montana',
                :NC => 'North Carolina',
                :ND => 'North Dakota',
                :NE => 'Nebraska',
                :NH => 'New Hampshire',
                :NJ => 'New Jersey',
                :NM => 'New Mexico',
                :NV => 'Nevada',
                :NY => 'New York',
                :OH => 'Ohio',
                :OK => 'Oklahoma',
                :OR => 'Oregon',
                :PA => 'Pennsylvania',
                :RI => 'Rhode Island',
                :SC => 'South Carolina',
                :SD => 'South Dakota',
                :TN => 'Tennessee',
                :TX => 'Texas',
                :UT => 'Utah',
                :VA => 'Virginia',
                :VT => 'Vermont',
                :WA => 'Washington',
                :WI => 'Wisconsin',
                :WV => 'West Virginia',
                :WY => 'Wyoming' }.freeze
  US_COUNTRY_CODE = 'US'

  def initialize(country = nil)
    @country = use_cities_gem ? country : US_COUNTRY_CODE
  end

  def states
    if use_cities_gem
      CS.states(country).invert
    else
      US_STATES.invert
    end
  end

  def use_cities_gem
    @use_cities_gem ||= ENV['USE_CITIES_GEM'] == 'true'
  end

  attr_reader :country
end
