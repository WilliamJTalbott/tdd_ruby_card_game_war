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
      terminal: @server.accept_nonblock, #TCP SOCKET CLASS
      name: player_name,
      ready: false,
      message_given: false
    }
    
    clients << client

    # associate player and client
    client[:terminal].puts "Welcome to War!"
  rescue IO::WaitReadable, Errno::EINTR
    puts "No client to accept"
  end

  def create_game_if_possible

    return unless clients.count == CLIENTS_PER_GAME

    clients.each do |client|
      client[:terminal].puts "War is starting..."
    end

    game = WarGame.new(clients[0][:name], clients[1][:name])
    games << game

    game

  end

  def process_input
    clients.first[:terminal].gets.chomp
  end

  def run_game(game)

    clients.each do |client|
      client[:terminal].puts "Are you ready?" unless client[:message_given]
      client[:message_given] = true
    end

    return unless clients.all? { |h| h[:ready] == true }
    
  end

  def stop
    @server.close if @server
  end

end
