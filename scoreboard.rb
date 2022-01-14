#scores = Scoreboard.open
#s = Score.open_scores[0]
#s.add_result(1)
require 'json'
require 'colorize'
class Scoreboard
  SCORE_FILE = 'scores.json'

  attr_accessor :scores
  
  def pretty_print
    puts ""
    puts "========= SCOREBOARD =========".red
    sorted_scores[0..10].each do |s|
      puts "#{s.name.light_blue}: #{s.points.to_s.green} points in #{s.num_games.to_s.green} games. #{s.scores.inspect.light_yellow}"
    end
  end

  def sorted_scores
    @scores.sort{|a,b| a.points <=> b.points}
  end
  
  def update(name, num_guesses)
    my_score = @scores.detect{|s| s.name == name}
    if my_score.nil?
       s = Score.new(name)
       s.add_result(num_guesses)
       @scores << s
    else
      my_score.add_result(num_guesses)
    end
    my_score
  end
  
  def lose(name)
    update(name, Score::MAX_GUESSES+1)
  end
  
  def save!
    data = {}
    @scores.each do |s|
      # data[s.name] = s.to_json
      data[s.name] = {
        :num_games => s.num_games,
        :scores    => s.scores
      }
    end
    puts data.inspect
    File.write(SCORE_FILE, data.to_json)
  end

  def self.open
    scoreboard = Scoreboard.new
    data = JSON.parse(File.read(SCORE_FILE))
    scoreboard.scores = data.map do |k,v|
      Score.from_json(k,v)
    end
    scoreboard
  end

  class Score
    MAX_GUESSES = 6
    # [0,0,3,2,2,0]
    attr_accessor :name, :num_games, :scores
  
    def initialize(name)
      @name = name
      @num_games = 0
      @scores = [0,0,0,0,0,0]
    end
  
    def print
    
    end
  
    def add_result(num_guesses)
      @num_games +=1
      @scores[num_guesses-1] += 1 if num_guesses < MAX_GUESSES
    end

    def wins
      @scores.sum
    end
  
    def losses
      @num_games - wins
    end

    def points
      (@scores[1-1] * 8) + 
      (@scores[2-1] * 6) + 
      (@scores[3-1] * 4) + 
      (@scores[4-1] * 3) + 
      (@scores[5-1] * 2) +
      (@scores[6-1] * 1)
    end

    # data[@name] = {
    #   # :name => @name,
    #   :num_games => @num_games,
    #   :scores => @scores
    # }
    
    def to_json
      {
        # :name      => @name,
        :num_games => @num_games,
        :scores    => @scores
      }.to_json
    end
  
    def self.from_json(name, data)
      score = Score.new(name)
      score.num_games = data['num_games']
      score.scores = data['scores']
      score
    end
  
  end
end