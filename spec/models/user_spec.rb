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

require 'spec_helper'

describe User do
  let(:user) { Factory.create(:user) }
  subject { user }

  it { should validate_uniqueness_of(:username).case_insensitive }

  describe "#as_json" do
    subject { user.as_json }

    it { should include("username" => user.username) }
  end

  describe "#sync" do
    let(:session) { Factory.create(:session, :user => user) }
    let(:session2) { Factory.create(:session, :user => user, :notes => [note1, note2]) }
    let!(:session3) { Factory.create(:session, :user => user) }
    let(:session4) { Factory.create(:session, :user => user, :notes => [note3]) }
    let(:note1) { Factory.create(:note, :number => 1, :text => "Old text") }
    let(:note2) { Factory.create(:note, :number => 2, :text => "Old text") }
    let(:note3) { Factory.create(:note, :number => nil, :text => "Old text") }

    let(:data) do
      [
       { :uuid => session.uuid, :deleted => true },
       { :uuid => session2.uuid, :title => "New title", :notes =>
         [{ :number => 2, :text => "Bye" }, { :number => 1, :text => "Hi" }] },
       { :uuid => "something" },
       { :uuid => session4.uuid, :notes => [note3.attributes.merge(:text => "New text")] }
      ]
    end

    before { @result = user.sync(data) }

    it "should delete sessions" do
      Session.exists?(session.id).should be_false
    end

    it "should update sessions" do
      session2.reload.title.should == "New title"
    end

    it "should return a list of session uuids to upload" do
      @result[:upload].should == ["something"]
    end

    it "should return a list of session ids to download" do
      @result[:download].should == [session3.id]
    end

    it "should update notes matching numbers" do
      session2.notes.find_by_number(1).text.should == "Hi"
      session2.notes.find_by_number(2).text.should == "Bye"
    end

    it "should replace notes when there are no numbers" do
      session4.reload.notes.size.should == 1
      session4.notes.first.text.should == "New text"
    end
  end
end