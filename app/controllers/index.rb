get '/' do
  erb :index
end

get '/game/new' do
  erb :new_game
end

post '/game/new' do
  @game = Game.create_and_start_game(params[:first])
  redirect "/game/play/#{@game.id}"
end

get '/game/play/:id' do
  @game = Game.find(params[:id])
  @grid = @game.game_grid
  erb :game
end

post '/game/play/:id' do
  @game = Game.find(params[:id])
  if @game.finished?
    @grid = @game.game_grid
    @error = "Game is over.  Please start a new game"
    erb :game
  else
    player_move = Move.new(game_id: @game.id, location: params[:location], marker: @game.player_marker)
    if player_move.save
      unless @game.finished?
        next_ai_move(@game)
      end
      redirect "/game/play/#{@game.id}"
    else
      @grid = @game.game_grid
      @error = "That square is already taken.  Please try another square"
      erb :game
    end
  end
end
