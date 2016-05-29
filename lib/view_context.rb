class ViewContext
  attr_reader :current_game, :history, :answer, :result

  def initialize(current_game, history, answer, result)
    @current_game = current_game
    @history = history
    @answer = answer
    @result = result
  end

  def get_binding
    binding
  end

  def game_in_progress?
    current_game && !current_game.completed?
  end

  def game_finished?
    current_game && current_game.completed?
  end

  def game_win?
    current_game.game_status == 'win'
  end
end
