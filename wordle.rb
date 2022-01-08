require 'colorize'

ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

VALID_WORDS = File.read("words.lower.txt").split("\n")
def valid_word?(word)
  VALID_WORDS.include?(word)
end

MAX_GUESSES = 6
LENGTH = 5
WORDS = %w[
  a
  hi
  yes
  gabi
  kugel
  chests
  ezekiel
  benjamin
]
# WORD = WORDS[LENGTH-1]

#ENTER WORD HERE
puts "SETTER: Enter your #{LENGTH} letter word here:"
WORD = gets.chomp
raise "You must guess a valid word in the dictionary. Try again." if !valid_word?(WORD)

puts "Got it! #{WORD} is a great word. To hide this, press command-k now."

raise "Word length of #{WORD} must be #{LENGTH}" if WORD.size != LENGTH

#puts "shhh the word is '#{WORD}'"


def print_blank_row(input=nil)
  str = "_ " * LENGTH
  puts str
end

def color_word(word, guess)

  str = ""
#   guess.split("").each_with_index do |letter, index|
#     # puts "The #{index} letter is #{letter}"
# puts "Word=#{word}"
#     # str << if letter == WORD[index]
#     #   word = word.gsub(letter,"_")
#     #   letter.green
#     # elsif word.match?(letter)
#     #   word = word.gsub(letter,"_")
#     #   letter.yellow
#     # else
#     #   letter
#     # end
#   end

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
#      ALPHABET.gsub!(letter, letter.green)
      letter.green
      
    elsif yellows[index]
#      ALPHABET.gsub!(letter, letter.yellow)
      letter.yellow
    else
#      ALPHABET.gsub!(letter, letter.light_black)
      letter.light_black
    end
    
  end
  str
end

def correct?(word, guess)
  word == guess
end

puts "Make a guess"
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
      puts "You win! 🐶 The word was #{WORD}".green
      exit
    end
    num_guesses+=1
  end
  puts "Guess again (#{MAX_GUESSES-num_guesses} left)"
end
puts "YOU LOSE 💀. The word was #{WORD}.".red



