class Player
  WINNING_SCORE = 21

  attr_accessor :name, :cards

  def initialize
    @name = self.class
    @cards = []
  end

  def busted?
    total > WINNING_SCORE
  end

  def total
    cards.map(&:value).sum
  end

  def <<(card)
    if card.face == 'Ace'
      card.value = if total + 11 <= WINNING_SCORE
                     11
                   else
                     1
                   end
    end
    cards << card
  end

  def to_s
    cards.each(&:to_s)
  end
end

class Dealer < Player
  MAX_HIT_SCORE = 17

  attr_accessor :deck

  def initialize
    super
    @deck = Deck.new
    setup_deck
  end

  def stay?
    total >= MAX_HIT_SCORE && total <= WINNING_SCORE
  end

  def deal(recipient)
    recipient << deck.pop
  end

  def setup_deck
    deck.create
    deck.shuffle!
  end
end

class Deck
  SUITS = ['Hearts', 'Diamonds', 'Clubs', 'Spades']
  FACES = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)

  attr_accessor :cards

  def initialize
    @cards = []
  end

  def create
    SUITS.each do |suit|
      FACES.each do |face|
        cards << Card.new(suit, face)
      end
    end
  end

  def to_s
    cards.each(&:to_s)
  end

  def shuffle!
    cards.shuffle!
  end

  def pop
    cards.pop
  end
end

class Card
  attr_accessor :suit, :face, :value

  def initialize(suit, face)
    @suit = suit
    @face = face
    @value = non_ace_value
  end

  def to_s
    suit + " of " + face
  end

  def non_ace_value
    return 0 if face == 'Ace'
    return face.to_i unless face.to_i == 0
    10
  end
end

class Game
  attr_accessor :player, :dealer

  def initialize
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    display_welcome_message
    deal_cards
    show_initial_cards
    player_turn
    dealer_turn if !player.busted?
    show_result
    display_player_cards
    display_exit_message
  end

  private

  def display_welcome_message
    puts "Welcome to the card came of Twenty-One!"
  end

  def display_exit_message
    puts "\nThank you for playing Twenty-One. Goodbye!"
  end

  def deal_cards
    2.times { |_| dealer.deal(player) }
    2.times { |_| dealer.deal(dealer) }
  end

  def show_initial_cards
    puts "\nThe player's initial cards are as follows:"
    puts player.cards
    puts "\nThe dealer's initial cards are as follows:"
    puts dealer.cards[0]
    puts "Hidden\n"
  end

  def player_turn
    puts "\nIt is your turn to play."
    choice = nil
    loop do
      display_player_cards
      choice = player_choice
      dealer.deal(player) if choice == 'hit'
      break if choice == 'stay' || player.busted?
    end
    puts "You busted." if player.busted?
    puts "You have chosen to stay." if choice == 'stay'
    display_player_cards
  end

  def player_choice
    choice = hit_or_stay
    choice = 'hit' if choice == 'h'
    choice = 'stay' if choice == 's'
    choice
  end

  def hit_or_stay
    choice = nil
    loop do
      puts "\nWhat would you like to do now? (h)it/(s)tay):"
      choice = gets.chomp.downcase
      break if ['hit', 'h', 'stay', 's'].include?(choice)
      puts "You're choice is invalid. Please try again."
    end
    choice
  end

  def display_player_cards
    puts "\nYou're current cards are as follows:"
    puts player.cards
    puts "You have a current score of: #{player.total}"
  end

  def dealer_turn
    while !(dealer.busted? || dealer.stay?)
      dealer.deal(dealer)
    end
  end

  def show_result
    system 'clear'

    my_score = player.total
    dealer_score = dealer.total

    puts
    if player.busted?
      puts "You busted and lost."
    elsif dealer.busted?
      puts "Dealer busted. You won at a score of #{my_score}."
    elsif dealer_score > my_score
      puts "The dealer won with a score of #{dealer_score}."
    elsif dealer_score < my_score
      puts "You won with a score of #{my_score}."
    else
      puts "It is a tie. Both parties recieved a score of #{my_score}."
    end
  end
end

Game.new.start
