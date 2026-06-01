require_relative '../lib/war_player'

describe 'WarPlayer' do

  it "has an empty hand" do
    player = WarPlayer.new("Bob")
    expect(player.hand).to eq []
  end

  it 'given valid name' do
    expect {
      WarPlayer.new(1)
    }.to raise_error WarPlayer::InvalidName
  end

end
