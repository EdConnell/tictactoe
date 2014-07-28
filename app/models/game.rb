class Game < ActiveRecord::Base
  has_many :moves

  def self.create_and_start_game(first_player)
    new_game = self.create(first_player: first_player.downcase)
    if new_game.first_player == "computer"
      AI.new(new_game).find_next_move!
    end
    new_game
  end

  def game_grid
    grid = Hash.new
    (0..8).each do |location|
      this_location = self.moves.where(location: location)
      if this_location.length > 0
        grid[location] = this_location.first.marker
      else
        grid[location] = nil
      end
    end
    grid
  end

  def player_marker
    self.first_player == "player" ? "X" : "O"
  end

  def cpu_marker
    self.first_player == "computer" ? "X" : "O"
  end

  def winning_triples
    [
    [0,1,2],
    [3,4,5],
    [6,7,8],
    [0,3,6],
    [1,4,7],
    [2,5,8],
    [0,4,8],
    [2,4,6],
    ]
  end

  def finished?
    return true if self.winner != nil
    if (check_for_player_win || check_for_cpu_win)
      puts "True from first if"
      true
    elsif self.moves.count == 9
      self.winner = "Tie"
      self.save
      true
    else
      nil
    end
  end

  def check_for_player_win
    @grid ||= self.game_grid
    winning_triples.each do|triple|
      if triple.all? {|cell| @grid[cell] == player_marker}
        self.winner = "Player"
        self.save
        puts "Player won"
        return true
      end
    end
    false
  end

  def check_for_cpu_win
    @grid ||= self.game_grid
    winning_triples.each do|triple|
      if triple.all? {|cell| @grid[cell] == cpu_marker}
        self.winner = "Computer"
        self.save
        return true
      end
    end
    false
  end
end
