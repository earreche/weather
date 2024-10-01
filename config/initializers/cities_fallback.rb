# frozen_string_literal: true

require 'yaml'

CITIES = YAML.load_file(Rails.root.join('config', 'cities.yml'))
