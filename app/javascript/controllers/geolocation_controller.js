import { Controller } from "@hotwired/stimulus"
import { fetchWithTurbo } from '../modules/utils/fetchWithTurbo';

const options = {
  enableHighAccuracy: true,
  maximumAge: 0,
  timeout: 5000 // 5 seconds timeout
};

const mockedResponse = {
  coords: {
    latitude: '-34.901112',
    longitude: '-56.164532'
  }
};

export default class extends Controller {
  static values = { envirorment: String }
  static targets = ['city', 'country']

  connect() {
    this.getLocation();
  }
  
  getLocation() {
    if (this.envirormentValue != 'test'){
      navigator.geolocation.getCurrentPosition(this.success.bind(this), this.error, options);
    }else{
      this.success(mockedResponse)
    }
  }

  getCityWeather() {
    let params = new URLSearchParams();
    params.append('city', this.cityTarget.value)
    params.append('country', this.countryTarget.value)

    fetchWithTurbo(`/query_by_city?${params}`);
  }
  
  success(pos) {
    const crd = pos.coords;
    fetchWithTurbo(`/query_by_position?lat=${crd.latitude}&long=${crd.longitude}`);
  }

  error(err) {
    console.warn(`ERROR(${err.code}): ${err.message}`);
  }
}
