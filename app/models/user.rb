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

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  #   :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :token_authenticatable

  has_many :sessions

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :username, :login, :password, :password_confirmation, :remember_me, :send_emails

  # Virtual attribute for devise
  attr_accessor :login

  before_create :ensure_authentication_token

  validates :username, :presence => true
  validates_uniqueness_of :username, :case_sensitive => false

  def as_json(*args)
    super(:only => [:id, :email, :username, :authentication_token])
  end

  # Copied from devise wiki
  def self.find_for_database_authentication(conditions)
    conditions = conditions.dup
    login = conditions.delete(:login)
    login ||= conditions.delete(:authentication_token)

    where(conditions).
      where(["authentication_token = :token OR " +
             "lower(username) = :value OR " +
             "lower(email) = :value",
             { value: login.downcase,
               token: login
             }]).
      first
  end

  # Adapted from devise wiki
  def self.send_reset_password_instructions(conditions = {})
    record = find_for_database_authentication(conditions)
    record.send_reset_password_instructions if record
    record
  end

  def sync(data)
    upload = []

    for session_data in data
      session = sessions.find_by_uuid(session_data[:uuid])
      if session && session_data[:deleted]
        session.destroy
      elsif session
        session.sync(session_data)
      else
        upload << session_data[:uuid]
      end
    end

    # Apparently NOT IN doesn't work if uuids is empty
    uuids = data.map { |x| x[:uuid] } + [""]
    download = sessions.
      find(:all, :conditions => ["uuid NOT IN (?)", uuids]).
      map(&:id)

    { :upload => upload, :download => download }
  end
end