class HomeController < ApplicationController
  include ApplicationHelper

  def index
  end

  def result
    @generated_text = generate_response(params[:text_prompt])
    @generated_image = generate_image(params[:image_prompt])
  end
end
