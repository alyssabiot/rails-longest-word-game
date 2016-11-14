require 'open-uri'
require 'json'

class GameController < ApplicationController
  def game
    @grid = (1..10).map { ("A".."Z").to_a[rand(26)] }
  end

  def score
    @end_time = Time.now
    @grid = params[:grid].split("")
    @attempt = params[:attempt]
    @start_time = Time.parse(params[:start_time])
    @duration = @end_time - @start_time

    @translation = translate(@attempt)
    if !in_grid?(@attempt, @grid)
      @score = 0
      @message = "Not in the grid"
      @translation = nil
    elsif @translation == @attempt
      @score = 0
      @message = "Not an english word"
      @translation = nil
    else
      @score = @attempt.length*100 / @duration.round
      @message = "Well done"
    end
    session[:number] = session[:number].to_i + 1
    session[:score_tot] = session[:score_tot].to_i + @score
    session[:average] = session[:score_tot] / session[:number]
  end

  def translate(word)
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=85680a5e-ac22-4af8-a83e-5a627d114819&input=#{word}"
    word_serialized = open(url).read
    word = JSON.parse(word_serialized)
    return word["outputs"][0]["output"]
  end

  def in_grid?(attempt, grid)
    result = true
    tmp_grid = @grid
    @attempt.upcase.chars.each do |letter|
      if tmp_grid.include?(letter)
        tmp_grid = tmp_grid.join.sub(letter, "").split("")
      else
        result = false
      end
    end
    return result
  end

end
