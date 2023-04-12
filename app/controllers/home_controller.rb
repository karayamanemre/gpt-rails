class HomeController < ApplicationController
  include ApplicationHelper

  def index
  end

  def result
    text_prompt = params[:text_prompt]
    result = generate_text_and_image(text_prompt)

    @generated_text = result[:text]
    @generated_image = result[:image_url]
  end
end