class HomeController < ApplicationController
  include ApplicationHelper

  def index
  end

  def result
    generate_text = params[:text] == 'true'
    generate_image = params[:image] == 'true'
    
    if generate_text
      @generated_text = generate_response(params[:text_prompt])
    end
    
    if generate_image
      @generated_image = generate_image(params[:image_prompt])
    end
  end
end