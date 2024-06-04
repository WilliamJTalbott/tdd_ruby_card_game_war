require 'socket'
require_relative '../lib/war_socket_server'

class MockWarSocketClient
  attr_reader :socket
  attr_reader :output

  def initialize(port)
    @socket = TCPSocket.new('localhost', port)
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def capture_output(delay=0.1)
    sleep(delay)
    @output = @socket.read_nonblock(1000) # not gets which blocks
  rescue IO::WaitReadable
    @output = ""
  end

  def close
    @socket.close if @socket
  end
end

describe WarSocketServer do
  before(:each) do
    @clients = []
    @server = WarSocketServer.new
    @server.start
    sleep 0.1 # ensure server is started
  end

  after(:each) do
    @server.stop
    @clients.each do |client|
      client.close
    end
  end

  it "is not listening on a port before it is started"  do
    @server.stop
    expect {MockWarSocketClient.new(@server.port_number)}.to raise_error(Errno::ECONNREFUSED)
  end

  it "accepts new clients and starts a game if possible" do
    client1 = MockWarSocketClient.new(@server.port_number)
    @clients.push(client1)
    @server.accept_new_client("Player 1")
    @server.create_game_if_possible
    expect(@server.games.count).to be 0
    client2 = MockWarSocketClient.new(@server.port_number)
    @clients.push(client2)
    @server.accept_new_client("Player 2")
    @server.create_game_if_possible
    expect(@server.games.count).to be 1
  end

  # Add more tests to make sure the game is being played

  it "tells pending player that he's waiting" do
    client1 = MockWarSocketClient.new(@server.port_number)
    @server.accept_new_client("Player 1")
    expect(client1.capture_output).to eq("Welcome.  Waiting for another player to join.\n")
    client2 = MockWarSocketClient.new(@server.port_number)
    @server.accept_new_client("Player 1")
    expect(client2.capture_output).to eq("Welcome.  You are about to go to war.\n")
    client3 = MockWarSocketClient.new(@server.port_number)
    @server.accept_new_client("Player 1")
    expect(client3.capture_output).to eq("Welcome.  Waiting for another player to join.\n")
  end

  context "game started" do
    before(:each) do
      client1 = MockWarSocketClient.new(@server.port_number)
      @clients.push(client1)
      @server.accept_new_client("Player 1")
      client1.capture_output
      @server.create_game_if_possible
      client2 = MockWarSocketClient.new(@server.port_number)
      @clients.push(client2)
      client2.capture_output
      @server.accept_new_client("Player 2")
      @server.create_game_if_possible
    end

    it "Tells each player how many cards they have left" do
      @clients.each do |client|
        expect(client.capture_output).to eq "You have 26 cards left"
      end
    end
  end
  # For example:
  #   make sure the mock client gets appropriate output
  #   make sure the next round isn't played until both clients say they are ready to play
  #   ...
end
