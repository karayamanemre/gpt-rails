require 'net/http'
require 'uri'
require 'json'

DEFAULT_IMAGE_URL = 'https://via.placeholder.com/480x480?text=Image+Not+Available'


module ApplicationHelper
  def generate_response(prompt)
    api_key = ENV.fetch("OPENAI_API_KEY")
    engine = "text-davinci-003"

    openai_client = OpenAI::Client.new(api_key: api_key, default_engine: engine)
    response = openai_client.completions(prompt: prompt, max_tokens: 1000)
    text = response.choices[0].text
  end

  def generate_image(image_prompt, style, color)
    api_key = ENV.fetch("OPENAI_API_KEY")
    size = "512x512"
    prompt = "#{style} #{color} #{image_prompt}"
    endpoint = "https://api.openai.com/v1/images/generations"

    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    headers = {
      'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{api_key}"
    }
    body = {
      'model' => 'image-alpha-001',
      'prompt' => prompt,
      'num_images' => 2,
      'size' => size,
      'response_format' => 'url'
    }.to_json

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      image_urls = parsed_response["data"].map { |image_data| image_data["url"] }
      if image_urls.any?(&:nil?)
        Rails.logger.error "Error generating image: Image URL is nil. Response: #{response.body}"
        Array.new(2, DEFAULT_IMAGE_URL)
      else
        Rails.logger.info "Generated image URLs: #{image_urls.join(', ')}"
        image_urls
      end
    else
      Rails.logger.error "Error generating image: API request failed. Status: #{response.code}. Response: #{response.body}"
      Array.new(2, DEFAULT_IMAGE_URL)
    end
  rescue StandardError => e
    Rails.logger.error "Error generating image: #{e.message}"
    Array.new(2, DEFAULT_IMAGE_URL)
  end


  def generate_image_description(text)
    prompt = "Create a DALL-E image prompt for the following text: '#{text}'"
    image_description = generate_response(prompt)
    image_description.strip
  end

  def generate_text_and_image(prompt, style, color)
    text_response = generate_response(prompt)
    image_description = generate_image_description(text_response)
    image_url = generate_image(image_description, style, color)
    {
      text: text_response.strip,
      image_url: image_url
    }
  end

end