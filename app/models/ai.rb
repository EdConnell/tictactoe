class AI
  attr_reader :marker

  CORNERS = [0,2,6,8]
  EDGES = [1,3,5,7]
  CENTER = 4
  WIN = [
        [0,1,2],
        [3,4,5],
        [6,7,8],
        [0,3,6],
        [1,4,7],
        [2,5,8]
        ]
  MARKERS = ["O", "X"]

  OPPOSITE_CORNERS = {
                      0: 8,
                      2: 6,
                      6: 2,
                      8: 0
                      }

  def initialize(game)
    @game = game
    set_marker
  end

  def find_next_move!
    if first_move?
      if me_first?
        make_first_move
      else
        case
        when CORNERS.include?(player_first_move)
          CENTER
        when EDGES.include?(player_first_move)
          make_first_move
        else # CENTER
          CORNERS.sample
        end
      end
    elsif second_move?
      if i_have_a_corner?
        if player_has_center?
          opposite_corner(my_moves.first)
        else
        end
      end
    else
      #rest of game
    end
  end

  def set_marker
    if me_first?
      @marker = "X"
    else
      @marker = "O"
    end
  end

  def make_move!(space)
    my_move = @game.moves.build(location: space, marker: marker)
    unless my_move.save
      raise "Something went wrong saving my move for game: #{@game.id} at the location: #{space}"
    end
  end

  def first_move?
    @game.moves.where(marker: marker).count == 0
  end

  def second_move?
    @game.moves.where(marker: marker).count == 1
  end

  def me_first?
    @game.first_player == "Computer"
  end

  def player_has_center?
    players_moves.include?(CENTER)
  end

  def i_have_center?
    my_moves.include?(CENTER)
  end

  def i_have_a_corner?
    my_moves.any? {|move| CORNERS.include?(move)}
  end

  def player_moves
    @game.moves.where('marker != ?', marker).pluck(:location)
  end

  def my_moves
    @game.moves.where(marker: marker).pluck(:location)
  end

  def make_first_move
    [CORNERS.sample, CENTER].sample # Randomly choose a corner or the center for initial move
  end

  def opposite_corner(corner)
    OPPOSITE_CORNERS[corner]
  end

end
