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
AC.Views.Maps ||= {}

class AC.Views.Maps.HudTabs extends Backbone.View
  template: JST["backbone/templates/maps/hud_tabs"]

  events:
    'click #crowd-map-tab-header': 'activateCrowdMap'
    'click #sessions-tab-header' : 'activateSessions'

  initialize: (options) ->
    @googleMap = options.googleMap

  render: ->
    $(@el).html @template()

    @crowdMapView = new AC.Views.Maps.CrowdMapView(
      el: $('#crowd-map-tab')
      googleMap: @googleMap
    ).render()

    @sessionsView = new AC.Views.Maps.SessionsView(
      el: $('#sessions-tab')
      googleMap: @googleMap
      includeSessionId: @options.sessionId
    ).render()

    if @options.sessionId?
      @activateSessions(selectedSessionId: @options.sessionId)
    else
      @activateCrowdMap()

    this

  activateCrowdMap: ->
    return false if @currentView == @crowdMapView

    @currentView = @crowdMapView
    @updateUi()
    return false

  activateSessions: (options) ->
    return false if @currentView == @sessionsView

    @currentView = @sessionsView
    @updateUi(options)
    return false

  updateUi: (options) ->
    if @currentView == @crowdMapView
      $('#crowd-map-tab-header').addClass('active')
      $('#sessions-tab-header').removeClass('active')
      $('#sessions-tab').hide()
      $('#crowd-map-tab').show()
      @sessionsView.deactivate()
      @crowdMapView.activate(options)
    else
      $('#sessions-tab-header').addClass('active')
      $('#crowd-map-tab-header').removeClass('active')
      $('#crowd-map-tab').hide()
      $('#sessions-tab').show()
      @crowdMapView.deactivate()
      @sessionsView.activate(options)