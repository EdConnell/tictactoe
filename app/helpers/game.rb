def grid_layout
  [[0,1,2], [3,4,5], [6,7,8]]
end

def next_ai_move(game)
  AI.new(game).find_next_move!
end
