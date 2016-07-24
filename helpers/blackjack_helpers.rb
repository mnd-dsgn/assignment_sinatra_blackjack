module BlackjackHelpers

  def save_game_state(game)
    session['deck'] ||= game.deck.cards
    session['player_hand'] = game.player.hand
    session['dealer_hand'] = game.dealer.hand
  end

  def player_hand_value(hand)
    aces = 0
    remaining = aces - 1
    values = hand.map{ |card| card[0] }
    sum = 0
    values.each do |value|
      value == 13 ? aces += 1 : sum += [value, 10].min
    end

    if aces > 0
      return sum + 11 + remaining if sum + 11 + remaining <= 21
      return sum + aces if sum + 11 + remaining > 21 
    end

    sum
  end

  def game_over?(hand)
    bust?(hand, 'player_hand_value') || blackjack?(hand, 'player_hand_value')
  end

  def bust?(hand, method)
    return true if send(method.to_sym, hand) > 21
    false
  end

  def blackjack?(hand, method)
    return true if send(method.to_sym, hand) == 21
    false
  end

  def dealer_hand_value(hand)
    aces = 0
    values = hand.map{ |card| card[0] }
    sum = 0
    values.each do |value|
      value == 13 ? aces += 1 : sum += [value, 10].min
    end

    if aces > 0
      remaining = aces - 1
      high_sum = sum + remaining + 11
      # soft 17 edge case
      
      return sum + remaining + 1  if high_sum == 17
      return  high_sum if high_sum > 17 && high_sum <= 21 
      
    end
    sum + aces
  end

  def dealer_wins?(player_hand, dealer_hand)
    return true if dealer_hand_value(dealer_hand) > player_hand_value(player_hand) &&  dealer_hand_value(dealer_hand) <= 21
    false
  end


end