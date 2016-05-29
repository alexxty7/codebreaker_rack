require 'erb'
require_relative 'view_context'

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
    @history = Codebreaker::Game.load_result('data.yml')
    @answer = @request.session[:guess]
    @result = @request.session[:result]
    render('show')
  end

  def new_game
    @request.session.clear
    game = Codebreaker::Game.new
    @request.session[:game_hash] = game.to_h
    redirect_to('game')
  end

  def check_guess
    answer = @request.params['guess']
    @request.session[:guess] = answer
    @request.session[:result] = current_game.check_guess(answer)
    @request.session[:game_hash] = current_game.to_h
    redirect_to('game')
  end

  def save_result
    return unless user_name = @request.params['user_name']
    current_game.save_result(user_name, 'data.yml')
    redirect_to('game')
  end

  def hint
    hint = current_game.hint
    @request.session[:game_hash] = current_game.to_h
    Rack::Response.new(hint)
  end

  def not_found
    Rack::Response.new('Not Found', 404)
  end

  def about
    render('about')
  end

  private

  def current_game
    return nil unless @request.session[:game_hash]
    @game ||= Codebreaker::Game.new(@request.session[:game_hash])
  end

  def render(template)
    Rack::Response.new(render_with_layout(template))
  end

  def redirect_to(path)
    Rack::Response.new { |response| response.redirect("/#{path}") }
  end

  def render_with_layout(template_path)
    path = File.expand_path("../views/game/#{template_path}.html.erb", __FILE__)
    context = ViewContext.new(current_game, @history, @answer, @result)
    render_layout do
      ERB.new(File.read(path)).result(context.get_binding)
    end
  end

  def render_layout(layout_path = 'application')
    layout = File.expand_path("../views/layouts/#{layout_path}.html.erb", __FILE__)
    ERB.new(File.read(layout)).result(binding)
  end
end
