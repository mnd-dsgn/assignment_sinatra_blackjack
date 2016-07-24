class Player

  attr_reader :hand

  def initialize(hand = nil)
    hand ||= []
    @hand = hand
  end

  def draw(cards)
    @hand << cards.pop
  end

end