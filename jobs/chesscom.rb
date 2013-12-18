require 'open-uri'
require 'uri'

CHESSCOM_EVERY = ENV['CHESSCOM_EVERY'] || "5m"
CHESSCOM_USERNAME = ENV['CHESSCOM_USERNAME']

abort "Need CHESSCOM_USERNAME to be set" unless CHESSCOM_USERNAME

class Chesscom
  VIEW_MEMBER = "http://www.chess.com/members/view/%{username}"
  FEN_JS = %r{acd_register\("\d+", "([^"]+)"}
  FEN_BOARD = "//www.chess.com/diagram?fen=%{fen}"

  def self.extract_fens(username)
    content = open(VIEW_MEMBER % { :username => username }).read
    content.scan(FEN_JS).map(&:first)
  end

  def self.board_url(fen)
    fen = URI.encode(fen)
    FEN_BOARD % { :fen => fen }
  end

  def initialize(username, sender)
    @username = username
    @sender   = sender
  end

  def run
    fens = self.class.extract_fens(@username)
    if fens.any?
      board_url = self.class.board_url(fens.first)
      send_event(board_url)
    end
  end

  def send_event(board_url)
    @sender.send_event 'chesscom',
      url: board_url
  end
end

SCHEDULER.every CHESSCOM_EVERY, :first_in => 0 do
  Chesscom.new(CHESSCOM_USERNAME, SENDER).run
end
