class Move < ActiveRecord::Base
  belongs_to :game

  validates_uniqueness_of :location, scope: :game_id
  validates_presence_of :location
end
