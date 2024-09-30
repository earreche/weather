import { Controller } from "@hotwired/stimulus"
import { fetchWithTurbo } from '../modules/utils/fetchWithTurbo';

export default class extends Controller {
  static targets = ['country', 'state', 'city', 'button']
  static values = {
    urlState: String,
    urlCity: String
  }

  countrySelect() {
    let params = new URLSearchParams();
    params.append('target', this.stateTarget.id)
    params.append('country', this.countryTarget.value)
    const url = this.urlStateValue;
    this.stateTarget.innerHTML = '';

    fetchWithTurbo(`${url}?${params}`);
    this.stateTarget.disabled = false;
    this.cityTarget.innerHTML = '';
    this.cityTarget.disabled = true;
  }

  stateSelect() {
    let params = new URLSearchParams();
    params.append('target', this.cityTarget.id)
    params.append('state', this.stateTarget.value)
    const url = this.urlStateValue;

    fetchWithTurbo(`${url}?${params}`);
    this.cityTarget.disabled = false;
    this.buttonTarget.disabled = false
  }

}
