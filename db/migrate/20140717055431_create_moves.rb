class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :game_id
      t.integer :location
      t.string :marker # either "X" or "O"
    end
  end
end
