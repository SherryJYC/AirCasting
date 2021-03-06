# AirCasting - Share your Air!
# Copyright (C) 2011-2012 HabitatMap, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# You can contact the authors by email at <info@habitatmap.org>

module Api
  module Realtime
    class SessionsController < BaseController
      require 'uri'

      INT_Q_ATTRS = [:time_from, :time_to, :day_from, :day_to]

      before_filter :authenticate_user!, only: :create

      respond_to :json

      def index
        data = decoded_query_data(params[:q])
        INT_Q_ATTRS.each { |key| data[key] = data[key].to_i if data.key?(key) }

        page = params[:page] || 0
        page_size = params[:page_size] || 50

        begin
          respond_with FixedSession.filtered_json(data, page, page_size)
        rescue WrongCoordinatesError => e
          error = { error: "Invalid Location" }
          respond_with error, status: :not_found
        end
      end

      def index_streaming
        data = decoded_query_data(params[:q])
        INT_Q_ATTRS.each { |key| data[key] = data[key].to_i if data.key?(key) }

        begin
          respond_with FixedSession.filtered_streaming_json(data)
        rescue WrongCoordinatesError => e
          error = { error: "Invalid Location" }
          respond_with error, status: :not_found
        end
      end

      def show
        session = FixedSession.find(params[:id])

        respond_with session, sensor_id: params[:sensor_id], methods: [:notes]
      end

      def sync_measurements
        session = FixedSession.find_by_uuid(params[:uuid]) or raise NotFound
        last_measurement_sync = URI.decode(params[:last_measurement_sync]).to_datetime
        stream_measurements = true

        response = session.as_synchronizable(stream_measurements, last_measurement_sync)

        respond_with response
      end

      def show_multiple
        data = decoded_query_data(params[:q])

        respond_with FixedSession.selected_sessions_json(data)
      end

      def create
        if params[:compression]
          decoded = Base64.decode64(params[:session])
          unzipped = AirCasting::GZip.inflate(decoded)
        else
          unzipped = params[:session]
        end
        photos = params[:photos] || []

        data = deep_symbolize ActiveSupport::JSON.decode(unzipped)
        session = SessionBuilder.new(data, photos, current_user).build!

        if session
          render json: session_json(session), status: :ok
        else
          render nothing: true, status: :bad_request
        end
      end

      private

      def decoded_query_data(query)
        if query.is_a?(String)
          ActiveSupport::JSON.decode(query).symbolize_keys
        elsif query
          query.symbolize_keys
        else
          {}
        end
      end

      def session_json(session)
        {
          location: short_session_url(session, host: AppConfig.host),
          notes: session.notes.map do |note|
            {
              number: note.number,
              photo_location: photo_location(note)
            }
          end
        }
      end
    end
  end
end
