require_relative '../lib/playing_card'

describe 'PlayingCard' do
  it "has rank and Suit" do
    card = PlayingCard.new("A", "Clubs")
    expect(card.rank).to eq "A"
    expect(card.suit).to eq "Clubs"
  end

  it "sets correct value" do
    card1 = PlayingCard.new("A", "Clubs")
    card2 = PlayingCard.new("2", "Clubs")
    expect(card1.value).to eq 12
    expect(card2.value).to_not eq 12
  end

  it 'card of the same rank and suit are equal' do
    card1 = PlayingCard.new("A", "Clubs")
    card2 = PlayingCard.new("10", "Clubs")
    card3 = PlayingCard.new("A", "Clubs")
    
    expect(card1).to eq card3
    expect(card1).to_not eq card2
  end
    
  it 'should allow valid ranks' do
    expect {
      PlayingCard.new("15", "Clubs")
  }.to raise_error PlayingCard::InvalidRank
  end

  it 'should allow valid suits' do
    expect {
      PlayingCard.new("A", "Minecraft")
  }.to raise_error PlayingCard::InvalidSuit
  end
end
