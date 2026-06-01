 class PlayingCard
   attr_reader :rank, :suit

  class InvalidRank < StandardError; end
  class InvalidSuit < StandardError; end

  RANKS = %w[ 2 3 4 5 6 7 8 9 10 J K Q A ]
  SUITS = %w[ Hearts Spades Clubs Diamonds ]

   def initialize(rank, suit)
    raise InvalidRank unless RANKS.include?(rank)
    raise InvalidSuit unless SUITS.include?(suit)
    @rank = rank
    @suit = suit
   end

   def ==(other_card)
     rank == other_card.rank && suit == other_card.suit
   end

 end
