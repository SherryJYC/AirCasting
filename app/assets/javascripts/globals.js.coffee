###
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
###
window.AirCasting.G =
  db_levels: [60, 70, 80]

window.AirCasting.util =
  colors: [
    [0x00, 0xA2, 0x3C]
    [0xFF, 0xD7, 0x00]
    [0xFF, 0x7E, 0x00]
    [0xFF, 0x00, 0x00]
  ]

  dbToColor: (value) ->
    result =
      if value < AC.G.db_levels[0]
        @colors[0]
      else if value < AC.G.db_levels[1]
        @colors[1]
      else if value < AC.G.db_levels[2]
        @colors[2]
      else
        @colors[3]
    "rgb(" + parseInt(result[0]) + "," + parseInt(result[1]) + "," + parseInt(result[2]) + ")"

  dbToIcon: (calibration, offset_60_db, value) ->
    value = @calibrateValue(calibration, offset_60_db, value)

    result =
      if value < AC.G.db_levels[0]
        window.marker1_path
      else if value < AC.G.db_levels[1]
        window.marker2_path
      else if value < AC.G.db_levels[2]
        window.marker3_path
      else
        window.marker4_path

  calibrateValue: (calibration, offset_60_db, value) ->
    (value + (calibration - 60 + offset_60_db)) / (calibration - 60 + offset_60_db) * (calibration - 60) + 60

  parseTime: (timeStr) ->
    time = Date.parse timeStr
    if timeStr.match(/(Z|00:00|0000)$/)
      time.addHours time.getTimezoneOffset() / -60
    time

  normalizeTimeSpan: (from, to) ->
    MINUTES_IN_DAY = 1440

    from = from + new Date().getTimezoneOffset()
    if from < 0
      from = MINUTES_IN_DAY + from

    to = to + new Date().getTimezoneOffset()
    if to < 0
      to = MINUTES_IN_DAY + to
    [from, to]

  viewport: (map) ->
    bounds = map.map.getBounds()
    if bounds
      {
        west: bounds.getSouthWest().lng(),
        east: bounds.getNorthEast().lng(),
        south: bounds.getSouthWest().lat(),
        north: bounds.getNorthEast().lat()
      }

  parseMinutesHours: (value) ->
    date = Date.parse(value)
    if date
      date.getMinutes() + 60 * date.getHours()

  
  spinner: {
    initialize: ->
      @spinnerTarget = document.getElementById('ajax-loader')

      spinnerOpts = {
        lines: 12,
        length: 0,
        width: 15,
        radius: 34,
        color: '#000',
        speed: 1.5,
        trail: 42,
        shadow: true
      }

      @spinner = new Spinner(spinnerOpts)
      @activeTasks = 0

    startTask: ->
      if @activeTasks == 0
        @spinner.spin(@spinnerTarget)
      @activeTasks += 1

    stopTask: ->
      @activeTasks -= 1
      if @activeTasks <= 0
        @activeTasks = 0
        @spinner.stop()
  }