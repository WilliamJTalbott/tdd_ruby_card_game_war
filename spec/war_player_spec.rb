require_relative '../lib/war_player'
require_relative '../lib/playing_card'

describe 'WarPlayer' do

  describe "initialize" do
    it "starts with empty hand" do
      player = WarPlayer.new("Bob")
      expect(player.hand).to eq []
    end

    it 'validates name' do
      expect {
        WarPlayer.new(1)
        WarPlayer.new(["Timmy"])
      }.to raise_error WarPlayer::InvalidName
    end
  end


  describe "play_card" do
    it "removes and returns the top card" do
      player = WarPlayer.new("Bob")
      cards = [PlayingCard.new("A", "Hearts"), PlayingCard.new("K", "Clubs")]
      player.hand = cards.dup
      expect(player.play_card).to eq cards.last
      expect(player.hand).to eq [cards.first]
    end
  end

  describe "win_cards" do
    it "it adds a number of cards" do
      player = WarPlayer.new("Bob")
      cards = [PlayingCard.new("A", "Hearts"), PlayingCard.new("K", "Clubs")]

      player.win_cards(cards.dup)
      expect(player.hand).to include(*cards)


    end
  end


end
