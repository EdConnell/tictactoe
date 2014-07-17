class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :first_player # Either "Computer"(AI), or "Human"
      t.timestamps
    end
  end
end
