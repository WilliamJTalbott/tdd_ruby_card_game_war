require 'socket'
require_relative "war_game"

class WarSocketServer

  CLIENTS_PER_GAME = 2

  def initialize
    @names = []
  end

  def port_number
    3336
  end

  def games
    @games ||= []
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def clients
    @clients ||= []
  end

  def accept_new_client(player_name)
    client = {
      socket: @server.accept_nonblock, #TCP SOCKET CLASS
      name: player_name,
      ready: false,
      message_given: false
    }
    
    clients << client

    # associate player and client
    client[:socket].puts "Welcome to War!"
  rescue IO::WaitReadable, Errno::EINTR
    puts "No client to accept"
  end

  def create_game_if_possible

    return unless clients.count == CLIENTS_PER_GAME

    clients.each { |client| client[:socket].puts "War is starting..." }

    game = WarGame.new(clients[0][:name], clients[1][:name])
    game.start

    games << game

    game

  end

  def get_input(client)
    socket = client[:socket]
    input = IO.select([socket], nil, nil, 0)
    return nil unless input

    socket.gets
    
  end

  def run_game(game)

    clients.each do |client|
      client[:socket].puts "Are you ready?" unless client[:message_given]
      client[:message_given] = true
      client[:ready] = true unless get_input(client).nil?
    end

    game.play_round if clients.all? { |h| h[:ready] == true }
    # game_over?(game)

  end

  # def game_over?(game)
  #   return false if game.winner.nil?

  #   clients.each do |client|
  #     client[:socket].puts "Winner: #{game.winner.name}"
  #   end

  #   stop
  # end

  def stop
    @server.close if @server
  end

end
