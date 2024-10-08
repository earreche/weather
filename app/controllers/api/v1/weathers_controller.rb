# frozen_string_literal: true

module API
  module V1
    class WeathersController < ::API::ApplicationController
      def index
        response = Weather::ForCityQueryService.new(response_service, city, state, country).call

        render json: response, status: response[:status]
      end

      private

      def permitted_params
        params.permit(:country, :state, :city)
      end

      def city
        @city ||= permitted_params[:city]
      end

      def state
        @state ||= permitted_params[:state]
      end

      def country
        @country ||= permitted_params[:country]
      end
    end
  end
end
