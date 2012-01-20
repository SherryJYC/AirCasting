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

class Api::UserSessionsController < Api::BaseController
  before_filter :authenticate_user!

  respond_to :json

  def sync
    data = JSON.parse(params[:data])
    symbolize!(data)

    respond_with(current_user.sync(data), :location => nil)
  end

  def show
    session = current_user.sessions.find_by_id(params[:id]) or raise NotFound

    respond_with session.as_json(:methods => [:measurements]).
      merge(:location => short_session_url(session)).
      merge(:tag_list => session.tag_list.join(" ")).
      merge(:notes => prepare_notes(session.notes))
  end

  private

  def prepare_notes(notes)
    notes.map do |note|
      note.as_json.merge(:photo_location => photo_location(note))
    end
  end

  def symbolize!(jsonish)
    if jsonish.kind_of?(Hash)
      jsonish.symbolize_keys!
      jsonish.each { |k,v| symbolize!(v) }
    else
      jsonish.each { |x| symbolize!(x) } if jsonish.respond_to?(:each)
    end
  end
end