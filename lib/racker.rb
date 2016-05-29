require 'erb'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case @request.path
    when '/' then index
    when '/game/new' then new_game
    when '/game' then show
    when '/game/check_guess' then check_guess
    when '/game/save_result' then save_result
    when '/game/hint' then hint
    when '/about' then about
    else not_found
    end
  end

  def index
    render('index')
  end

  def show
    @history = Codebreaker::Game.load_result
    @answer = @request.session[:guess]
    @result = @request.session[:result]
    render('show')
  end

  def new_game
    @request.session.clear
    @request.session[:game] = Codebreaker::Game.new
    redirect_to('game')
  end

  def check_guess
    answer = @request.params['guess']
    @request.session[:guess] = answer
    @request.session[:result] = current_game.check_guess(answer)
    redirect_to('game')
  end

  def save_result
    return unless user_name = @request.params['user_name']
    current_game.save_result(user_name)
    redirect_to('game')
  end

  def hint
    Rack::Response.new(current_game.hint)
  end

  def not_found
    Rack::Response.new('Not Found', 404)
  end

  def about
    render('about')
  end

  private

  def current_game
    @request.session[:game]
  end

  def render(template)
    Rack::Response.new(render_with_layout(template))
  end

  def redirect_to(path)
    Rack::Response.new { |response| response.redirect("/#{path}") }
  end

  def render_with_layout(template_path, context = self)
    path = File.expand_path("../views/game/#{template_path}.html.erb", __FILE__)
    render_layout do
      ERB.new(File.read(path)).result(binding)
    end
  end

  def render_layout(layout_path = 'application')
    layout = File.expand_path("../views/layouts/#{layout_path}.html.erb", __FILE__)
    ERB.new(File.read(layout)).result(binding)
  end
end
