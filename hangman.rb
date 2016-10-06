#Hangman implementation using ruby

class Player
	attr_accessor :word, :guess, :name
	def initialize(name)
		@name = name
		@guess = []
		@word = ""
	end
	#Creates word that needs to be guessed
	def set_word
		until @word.length >= 5 && @word.length <= 12
			puts "Enter a word between 5 and 12 characters long"
			@word = gets.chomp.downcase
		end
	end
	#Takes in user input and adds it to an array of guesses
	def make_guess
		puts "Make guess"
		@guess << gets.chomp.downcase
	end
end

class Game
	attr_accessor :players, :guesses
	def initialize
		@players = []
		@guesses = 6
	end
	#Checks to see if the word can be created with all guessed letters
	def word_guessed?(player)
		puts "#{@players[0].word}  #{@players[0].word.split("") - player.guess}"
		if (@players[0].word.split("") - player.guess).empty?
			puts "#{player.name} You Win! The word was #{players[0].word}"
			@guesses = 0
		end
	end
	#If guess is incorrect reduce number of guesses by 1
	def took_guess(player)
		puts "#{player.name} Your current guesses are #{player.guess}"
		if !players[0].word.include?(player.guess.last)
			@guesses -= 1
			puts "Sorry! No #{player.guess.last}!"
		else
			puts "Yes! There is an #{player.guess.last}!"
		end
		puts @guesses
	end
	#Ends game if number of guesses reaches 0
	def game_over?
		return true if @guesses <= 0
	end
	#Provides game rules, sets up game with new players
	def instructions
		puts "Hangman: In order to save a life you must guess the correct word.\nGuess one character at a time. Any letter that is not part of the word will decrease available guesses."
		puts "If an any point you wish to save the game, simply type 'save'"
		puts "Please select the number of players:"
		num_play = gets.chomp.to_i
		num_play.times do |i|
			puts "Player #{i}, what is your name?"
			name = gets.chomp
			players << Player.new(name)
		end
		if num_play == 1
			players.unshift(AIplayer.new("Computer"))
		end
	end
	def save_game(game)
		open(game,'w') { |f|
			f.puts players[0].name
			f.puts players[1].name
			f.puts guesses
			f.print "#{players[1].guess.join(" ")}\n"
			f.puts players[0].word
		}
		@guesses = 0
	end
	def load_game(file_name)
		open(file_name,'r') { |f|
			p1 = f.readline
			p2 = f.readline
			num_guess = f.readline
			guesses_arr = f.readline
			word = f.readline
			if  p1 == "computer"
			players << AIplayer.new(p1)
			else
				players << Player.new(p1)
			end
			players << Player.new(p2)
			@guesses = num_guess.to_i
			players[1].guess = guesses_arr.split(" ")
			players[1].guess.pop
			players[0].word = word.chomp
		}

	end
	def draw_board

	end
end

#Used to load in a random word when there is only 1 player
class Dictionary
	attr_accessor :word
	def load_word
		dict = IO.readlines("dictionary.txt")
		return @word = dict[rand(300)]
	end
	def is_valid?
		return false if @word.length < 5 || @word.length > 12
	end
end

class AIplayer < Player
	attr_accessor :word, :name
	def initialize(name)
		@name = name
		@word = ""
	end
	def set_word
		d = Dictionary.new
		until @word.length >= 5 && @word.length <= 12
			@word = d.load_word.chomp.downcase
		end
	end

end

def play_game
	puts "Load game? (y/n)"
	ans = gets.chomp
	cur_game = Game.new
	if ans == 'n'
		cur_game.instructions
		cur_game.players[0].set_word
	elsif ans == 'y'
		puts "Please type which game you would like to load"
		game_to_load = gets.chomp
		cur_game.load_game(game_to_load)
	else
	end
	while(!cur_game.game_over?) do
		cur_player = cur_game.players[1]
		cur_player.make_guess
		if cur_player.guess.last == 'save'
			puts "Please type a name to save file as"
			file_name = gets.chomp
			cur_game.save_game(file_name)


		end
		cur_game.took_guess(cur_player)
		cur_game.word_guessed?(cur_player)
	end
	puts "Game Over!"
end

def game_loop
	
end
play_game()