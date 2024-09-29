import { Turbo } from '@hotwired/turbo-rails';

export const fetchWithTurbo = (url) => {
  fetch(url, {
    headers: {
      Accept: 'text/vnd.turbo-stream.html',
      'X-Requested-With': 'XMLHttpRequest',
    },
  })
    .then(response => response.text())
    .then(htmlText => Turbo.renderStreamMessage(htmlText));
};

export default fetchWithTurbo;
