# frozen_string_literal: true

shared_context 'new weather wrapper context' do
  let(:payload) { current.merge(hourly).merge(daily) }
  let(:current_weather) do
    {
      'weather' => [
        {
          'id' => 803,
          'main' => 'Clouds',
          'description' => 'broken clouds',
          'icon' => '04d'
        }
      ]
    }
  end

  let(:current) do
    {
      'current' => {
        'temp' => 295.97,
        'feels_like' => 295.98,
        'pressure' => 1010,
        'humidity' => 64,
        'dew_point' => 288.81,
        **current_weather
      }
    }
  end

  let(:hourly) do
    {
      'hourly' => [
        {
          'dt' => 1_727_640_000,
          'temp' => 295.97,
          'feels_like' => 295.98,
          'weather' => [
            {
              'id' => 803,
              'main' => 'Clouds',
              'description' => 'broken clouds',
              'icon' => '04d'
            }
          ]
        }
      ]
    }
  end

  let(:daily) do
    {
      'daily' => [
        {
          'dt' => 1_727_622_000,
          'temp' => {
            'min' => 287.68,
            'max' => 295.97
          },
          'weather' => [
            {
              'id' => 804,
              'main' => 'Clouds',
              'description' => 'overcast clouds',
              'icon' => '04d'
            }
          ]
        }
      ]
    }
  end
end
