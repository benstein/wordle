require_relative 'scoreboard'
require 'colorize'
WORDLE_BANNER = 
" .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| | _____  _____ | || |     ____     | || |  _______     | || |  ________    | || |   _____      | || |  _________   | |
| ||_   _||_   _|| || |   .'    `.   | || | |_   __ \\    | || | |_   ___ `.  | || |  |_   _|     | || | |_   ___  |  | |
| |  | | /\\ | |  | || |  /  .--.  \\  | || |   | |__) |   | || |   | |   `. \\ | || |    | |       | || |   | |_  \\_|  | |
| |  | |/  \\| |  | || |  | |    | |  | || |   |  __ /    | || |   | |    | | | || |    | |   _   | || |   |  _|  _   | |
| |  |   /\\   |  | || |  \\  `--'  /  | || |  _| |  \\ \\_  | || |  _| |___.' / | || |   _| |__/ |  | || |  _| |___/ |  | |
| |  |__/  \\__|  | || |   `.____.'   | || | |____| |___| | || | |________.'  | || |  |________|  | || | |_________|  | |
| |              | || |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' "


# ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
ALPHABET = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
# ALPHABET = "abcdefghijklmnopqrstuvwxyz"


MAX_GUESSES = 6
MIN_LENGTH = 3
MAX_LENGTH = 9
SLEEP_FOR_BEFORE_STARTING = 0 #3

SOURCE_WORD_FILE = "source_words.sorted4-6.clean.txt"
DICTIONARY_FILE = "words.lower.txt"

VALID_WORDS = File.read(DICTIONARY_FILE).split("\n")
def valid_word?(word)
  VALID_WORDS.include?(word)
end


loop do
  #ENTER WORD HERE
  puts "Enter your word between #{MIN_LENGTH} and #{MAX_LENGTH} letters here and press enter, or just press enter for automatic picking"
  user_input = gets.chomp

  WORD = if user_input.size == 0 #autopicking
    File.read(SOURCE_WORD_FILE).split("\n").shuffle.last.chomp
  else
    user_input
  end
  LENGTH = WORD.size

  #Check the word is valid and a legal size
  if valid_word?(WORD) && (MIN_LENGTH..MAX_LENGTH).include?(LENGTH)
    break
  else
    puts "You must guess a valid word in the dictionary between #{MIN_LENGTH} and #{MAX_LENGTH} letters. Try again."
  end
  false
  #raise "Word length of #{WORD} must be #{LENGTH}" if WORD.size != LENGTH
end

puts "Got it! #{WORD} is a great word. Hiding in 3... 2... 1..."
sleep(SLEEP_FOR_BEFORE_STARTING)
system('clear')

def print_blank_row(input=nil)
  str = "_ " * LENGTH
  puts str
end

YELLOWS = []
GREENS  = []
GRAYS   = []

def color_word(word, guess)

  str = ""
  
  #first find greens
  greens = []
  bag = []
  guess.split("").each_with_index do |letter, index|
    greens << if letter == WORD[index]
      true
    else
      bag << WORD[index]
      false
    end
  end
  # puts greens.join
  
  #now check yellows
  yellows = []
  guess.split("").each_with_index do |letter, index|
    yellows << if bag.any?{|l| l == letter}
      bag.delete(letter)
      true
    else
      false
    end
  end
  # puts yellows.join

  str = ""
  guess.split("").each_with_index do |letter, index|
    str << if greens[index]
      # ALPHABET.gsub!(letter, letter.green)
      GREENS << letter
      letter.green
      
    elsif yellows[index]
      YELLOWS << letter
      # puts "TRYING TO GSUB #{letter}"
      # ALPHABET.gsub!(letter, letter.yellow)
      #ALPHABET.gsub!(letter, "_")
      # puts "ALPHABET: #{ALPHABET}"
      letter.light_yellow
    else
      GRAYS << letter
      # ALPHABET.gsub!(letter, letter.light_black)
      # ALPHABET.gsub!(letter, "_")
      letter.light_black
    end
    
  end
  str
end

def correct?(word, guess)
  word == guess
end

def color_alphabet
  str = ALPHABET.clone
  GRAYS.each{|l| str.gsub!(l.upcase, l.upcase.light_black) }
  (YELLOWS - GREENS).each{|l| str.gsub!(l.upcase, l.upcase.light_yellow) }
  GREENS.each{|l| str.gsub!(l.upcase, l.upcase.green) }
  str
end

puts WORDLE_BANNER.green
puts "Enter your name, or hit enter to just start guessing"
player_input = gets.chomp
PLAYER_NAME = (player_input.size==0) ? nil : player_input


puts "Hi #{PLAYER_NAME || 'anonymous'}. Guess the word. Hint: it's #{LENGTH} letters long."
num_guesses = 0

while(num_guesses < MAX_GUESSES)
  guess = gets.chomp
  if guess.length != LENGTH
    puts "You must guess a word with #{LENGTH} letters. Try again.".red
  elsif !valid_word?(guess)
    puts "You must guess a valid word in the dictionary. Try again.".red
  else
    puts color_word(WORD, guess)
    if correct?(WORD, guess)
      puts "You win! ???? The word was #{WORD}".green
      if PLAYER_NAME
        scoreboard = Scoreboard.open
        scoreboard.update(PLAYER_NAME, num_guesses+1)
        scoreboard.save!
      end
      Scoreboard.open.pretty_print
      exit
    end
    num_guesses+=1
  end
  puts "Guess again (#{MAX_GUESSES-num_guesses} left): #{color_alphabet}"
  
  # puts color_alphabet
  puts 
end
puts "YOU LOSE ????. The word was #{WORD}.".red
if PLAYER_NAME
  scoreboard = Scoreboard.open
  scoreboard.lose(PLAYER_NAME)
  scoreboard.save!
end
Scoreboard.open.pretty_print
