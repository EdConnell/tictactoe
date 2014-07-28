class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :first_player # Either "Computer"(AI), or "Player"
      t.string :winner
      t.timestamps
    end
  end
end
