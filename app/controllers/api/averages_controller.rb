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
  class AveragesController < BaseController
    FLOAT_Q_ATTRS = [:north, :south, :east, :west]
    INT_Q_ATTRS = [
      :time_from, :time_to,
      :day_from, :day_to,
      :year_from, :year_to,
      :grid_size_x, :grid_size_y
    ]

    def index
      data = params[:q].symbolize_keys
      FLOAT_Q_ATTRS.each { |key| data[key] = data[key].to_f if data.key?(key) }
      INT_Q_ATTRS.each { |key| data[key] = data[key].to_i if data.key?(key) }

      respond_with Measurement.averages(data)
    end
  end
end