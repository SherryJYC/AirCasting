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

class Note < ActiveRecord::Base
  belongs_to :session

  validates :text, :presence => true
  validates :date, :presence => true
  validates :latitude, :presence => true
  validates :longitude, :presence => true
  validates :session, :presence => true

  has_attached_file :photo, {
    :styles => { :thumbnail => "100x100", :medium => "600x600" },
    :url => "/system/:hash.:extension",
    :hash_secret => AppConfig.attachment_secret
  }

  def as_json(opts=nil)
    result = super(opts)

    if photo.exists?
      result.merge!({
        :photo => photo.url(:medium),
        :photo_thumbnail => photo.url(:thumbnail)
      })
    end

    result
  end
end