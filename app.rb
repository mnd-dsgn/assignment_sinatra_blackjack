#!/usr/bin/env ruby
require 'sinatra'
require 'sinatra/contrib'
require_relative 'deck'
require_relative 'blackjack'
require_relative 'player'
require_relative 'helpers/blackjack_helpers'

enable :sessions
helpers BlackjackHelpers


get '/' do
  session['bankroll'] = 1_000
  session['deck'] = nil
  erb :home
end


get '/bet' do 
  session['bankroll'] ||= 1_000
  erb :bet
end


post '/bet' do 
  if params[:bet_value].to_i > session['bankroll']
    session['bet_message'] = "You don't have that much guap."
    redirect '/bet'
  else
    session['bet_message'] = nil
    session['bet'] = params[:bet_value].to_i
    redirect '/blackjack'
  end
end


get '/blackjack' do

  game = Blackjack.new(session['deck'])
  game.start

  save_game_state(game)

  if blackjack?(session['player_hand'], 'player_hand_value')
    session['message'] = "You were dealt 21! You win this time, you lucky punk."
    redirect '/game_over'
  end

  erb :blackjack

end



post '/turn' do 

  game = Blackjack.new(session['deck'], session['player_hand'], session['dealer_hand'])
  save_game_state(game)

  if params[:hit] 
    game.player.draw(game.deck.cards)
    save_game_state(game)

    if game_over?(session['player_hand'])
      if bust?(session['player_hand'], 'player_hand_value')
        session['message'] = "You busted."
        session['bankroll'] -= session['bet']
      elsif blackjack?(session['player_hand'], 'player_hand_value') && blackjack?(session['dealer_hand'], 'dealer_hand_value')
        session['message'] = "You tied."
      else
        session['message'] = "You won! Winnings: #{session['bet'] * 1.5}"
        session['bankroll'] += session['bet'] * 1.5
      end
      redirect '/game_over'
    end
  else 
    until dealer_hand_value(game.dealer.hand) >= 17
      game.dealer.draw(game.deck.cards)
    end 
    save_game_state(game)
    
    if dealer_wins?(session['player_hand'], session['dealer_hand'])
     session['message'] = "The dealer wins."
     session['bankroll'] -= session['bet']
   else
     session['message'] = "You beat the dealer. This round's winnings: #{session['bet']}"
     session['bankroll'] += session['bet']
   end

   redirect '/game_over'
 end

 erb :blackjack

end


get '/game_over' do 
  erb :game_over
end