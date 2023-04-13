class HomeController < ApplicationController
  include ApplicationHelper

  def index
  end

  def result
    prompt = params[:text_prompt]
    style = params[:style]
    color = params[:color]
    @generated_data = helpers.generate_text_and_image(prompt, style, color)
    @generated_text = @generated_data[:text]
    @generated_image = @generated_data[:image_url]
  end
end