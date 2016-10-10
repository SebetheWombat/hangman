#TODO: Holy speghetti and meatballs Batman! You've got to refactor!

class Player
	attr_accessor :word, :guess, :name, :action
	def initialize(name)
		@name = name
		@guess = []
		@action = ""
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
		@action = ""
		puts "Make guess"
		user_input = gets.chomp.downcase
		validate_guess(user_input)
	end

	def check_duplicate(letter)
		return true if guess.include?(letter)
	end

	def validate_guess(letter)
		while check_duplicate(letter) || letter.length > 1 || (letter =~ /[^[a-z]]/) == 0
			if letter == 'save' || letter == 'quit'
				@action = letter
				break
			end
			if check_duplicate(letter)
				puts "You've already guessed #{letter}! Please try again"
				letter = gets.chomp.downcase
			elsif (letter =~ /[^[a-z]]/) == 0
				puts "Please only enter a single letter"
				letter = gets.chomp.downcase
			else
				puts "Please only enter in a single character at a time!"
				letter = gets.chomp.downcase
			end
		end

		if @action == ""
			guess << letter
		end
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
		if (@players[0].word.split("") - player.guess).empty?
			puts "#{player.name} You Win! The word was #{players[0].word}"
			@guesses = 0
		end
	end
	#If guess is incorrect reduce number of guesses by 1
	def took_guess(player)
		puts "#{player.name} Your current guesses are #{player.guess}"
		if player.action == 'save'
			puts "Saved!"
		elsif !players[0].word.include?(player.guess.last) && player.action == ""
			@guesses -= 1
			puts "Sorry! No #{player.guess.last}!"
		elsif player.action == ""
			puts "Yes! There is an #{player.guess.last}!"
		end
		draw_board(@guesses)
	end
	#Ends game if number of guesses reaches 0
	def game_over?
		return true if @guesses <= 0
	end
	#Provides game rules, sets up game with new players
	def instructions
		puts "Hangman: In order to save a life you must guess the correct word.\nGuess one character at a time. Any letter that is not part of the word will decrease available guesses."
		puts "If an any point you wish to save the game, simply type 'save'"
		puts "Please select 1 or 2 players:"
		num_play = gets.chomp.to_i
		while num_play != 1 && num_play != 2
			puts "Please select only 1 or 2 players"
			num_play = gets.chomp.to_i
		end
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
	end
	def quit
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
			players[0].word = word.chomp
		}
	end
	def draw_board(bodypart)
		add_bodyparts = [' |      O',' |      | ',' |      |/',' |     \|/',' |     / ',' |     / \\']
		board = [
			' --------',
			' |      |',
			' |',
			' |',
			' |',
			' |',
			' |',
			'-+-------'
		]

		if bodypart <= 5
			board[2] = add_bodyparts[0]
		end
		if bodypart <= 4
			board[3] = add_bodyparts[1]
			board[4] = add_bodyparts[1]
		end
		if bodypart <= 3
			board[3] = add_bodyparts[2]
		end
		if bodypart <= 2
			board[3] = add_bodyparts[3]
		end
		if bodypart <= 1
			board[5] = add_bodyparts[4]
		end
		if bodypart == 0
			board[5] = add_bodyparts[5]
		end

		puts board
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
	ans = gets.chomp.downcase
	cur_game = Game.new
	if ans == 'n'
		cur_game.instructions
		cur_game.players[0].set_word
	elsif ans == 'y'
		puts "Please type which game you would like to load"
		game_to_load = gets.chomp
		cur_game.load_game(game_to_load)
	else
		while ans != 'n' && ans != 'y'
			puts "Please only enter y or n"
			ans = gets.chomp.downcase
		end
	end
	while(!cur_game.game_over?) do
		cur_player = cur_game.players[1]
		cur_player.make_guess
		if cur_player.action == 'save'
			puts "Please type a name to save file as"
			file_name = gets.chomp
			cur_game.save_game(file_name)
		elsif cur_player.action == 'quit'
			break
		end
		cur_game.took_guess(cur_player)
		cur_game.word_guessed?(cur_player)
	end
	puts "Game Over!"
end

play_game()