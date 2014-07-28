class AI
  attr_reader :marker, :game

  CORNERS = [0,2,6,8]
  EDGES = [1,3,5,7]
  CENTER = 4
  WIN = [
        [0,1,2],
        [3,4,5],
        [6,7,8],
        [0,3,6],
        [1,4,7],
        [2,5,8],
        [0,4,8],
        [2,4,6],
        ]
  MARKERS = ["O", "X"]

  OPPOSITE_CORNERS_DIAG = {
                            0 => 8,
                            2 => 6,
                            6 => 2,
                            8 => 0
                          }

  OPPOSITE_CORNERS_COL = {
                          0 => 6,
                          2 => 8,
                          6 => 0,
                          8 => 2
                         }

  OPPOSITE_CORNERS_ROW = {
                          0 => 2,
                          2 => 0,
                          6 => 8,
                          8 => 6
                         }

  def initialize(game)
    @game = game
    set_marker
  end

  def find_next_move!
    if first_move?
      if me_first?
        make_first_move!
      else
        if player_has_corner?
          take_center!
        elsif player_has_an_edge?
          make_first_move!
        else # Player has center space
          take_open_corner!
        end
      end
    elsif second_move?
      if me_first?
        if i_have_a_corner?
          if player_has_center?
            take_opposite_corner_from_me!
          elsif player_has_an_edge?
            if edge_is_in_my_row?
              take_corner_in_coloumn!
            else
              take_corner_in_row!
            end
          else # Player took a corner
            take_center!
          end
        else # I have the center
          if player_has_corner?
            take_opposite_corner!
          else # Player took an edge
            take_open_corner!
          end
        end
      else # I'm second.  Player has had two moves
        if player_can_win?
          block_player!
        elsif player_has_two_corners?
          take_edge_space!
        else
          take_open_corner!
        end
      end
    else #Third turn and beyond
      if i_can_win?
        take_winning_spot!
      elsif player_can_win?
        block_player!
      else #No strategic places.  Most likely a tie.
        take_open_location!
      end
    end
  end

  def find_winning_triple
    WIN.select {|triple| check_almost_winning(triple, my_moves, player_moves)}.first
  end

  def find_location_to_block_player
    p WIN.select {|triple| check_almost_winning(triple, player_moves, my_moves)}.first
  end

  def set_marker
    if me_first?
      @marker = "X"
    else
      @marker = "O"
    end
  end

  def make_move!(space)
    space = space[0] if space.is_a? Array
    my_move = game.moves.build(location: space, marker: marker)
    unless my_move.save
      raise "Something went wrong saving my move for game: #{@game.id} at the location: #{space}"
    end
  end

  def first_move?
    game.moves.where(marker: marker).count == 0
  end

  def second_move?
    game.moves.where(marker: marker).count == 1
  end

  def me_first?
    game.first_player == "computer"
  end

  def player_has_center?
    player_moves.include?(CENTER)
  end

  def player_has_an_edge?
    player_moves.any? {|move| EDGES.include?(move)}
  end

  def player_has_corner?
    player_moves.any? {|move| CORNERS.include?(move)}
  end

  def player_has_two_corners?
    (CORNERS - player_moves).count == 2
  end

  def player_has_corner_and_center?
    (player_has_corner?  && player_has_center?)
  end

  def edge_is_in_my_row?
    WIN[0..2].select {|row| row.include?(my_first_move)}.include?(player_first_move)
  end

  def i_have_center?
    my_moves.include?(CENTER)
  end

  def i_have_a_corner?
    my_moves.any? {|move| CORNERS.include?(move)}
  end

  def i_can_win?
    find_winning_triple != nil
  end

  def player_can_win?
    WIN.any? {|triple| check_almost_winning(triple, player_moves, my_moves)}
  end

  def check_almost_winning(triple, target_moves, opponents_moves)
    return false if triple.any? {|location| opponents_moves.include?(location)} #Automatic false if player holds any locations in the triple
    times_in_triple = 0
    triple.each do |location|
      times_in_triple += 1 if target_moves.include?(location)
    end
    if times_in_triple == 2
      return true
    end
    false
  end

  def player_moves
    game.moves.where('marker != ?', marker).pluck(:location)
  end

  def illegal_moves
    game.moves.pluck(:location)
  end

  def player_first_move
    player_moves.first # Only called when calculating second move
  end

  def my_moves
    game.moves.where(marker: marker).pluck(:location)
  end

  def my_first_move
    my_moves.first # Only called when calculating second move
  end

  def make_first_move!
    make_move!([CORNERS.sample, CENTER].sample) # Randomly choose a corner or the center for initial move
  end

  def take_center!
    make_move!(CENTER)
  end

  def take_opposite_corner!
    make_move!(OPPOSITE_CORNERS_DIAG[player_first_move])
  end

  def take_opposite_corner_from_me!
    make_move!(OPPOSITE_CORNERS_DIAG[my_first_move])
  end

  def take_corner_in_coloumn!
    make_move!(OPPOSITE_CORNERS_COL[my_first_move])
  end

  def take_corner_in_row!
    make_move!(OPPOSITE_CORNERS_ROW[my_first_move])
  end

  def take_open_corner!
    make_move!((CORNERS - illegal_moves).sample)
  end

  def take_edge_space!
    make_move!((EDGES - illegal_moves).sample)
  end

  def take_winning_spot!
    make_move!(find_winning_triple.select {|location| !my_moves.include?(location) })
  end

  def block_player!
    make_move!(find_location_to_block_player.select {|location| !player_moves.include?(location)})
  end

  def take_open_location!
    make_move!((0..8).to_a - illegal_moves)
  end
end
