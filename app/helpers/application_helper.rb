require 'net/http'
require 'uri'
require 'json'

DEFAULT_IMAGE_URL = 'https://via.placeholder.com/480x480?text=Image+Not+Available'


module ApplicationHelper
  def generate_response
    api_key = ENV.fetch("OPENAI_API_KEY")
    engine = "text-davinci-003"
    prompt = "Write a post-apocalyptic short story."

    openai_client = OpenAI::Client.new(api_key: api_key, default_engine: engine)
    response = openai_client.completions(prompt: prompt, max_tokens: 1000)
    text = response.choices[0].text
  end

  def generate_image
    api_key = ENV.fetch("OPENAI_API_KEY")
    prompt = "Post-apocalyptic city view"
    size = "512x512"
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
      'num_images' => 1,
      'size' => size,
      'response_format' => 'url'
    }.to_json

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body
    response = http.request(request)

  if response.is_a?(Net::HTTPSuccess)
    parsed_response = JSON.parse(response.body)
    image_url = parsed_response.dig("data", 0, "url")
    if image_url.nil?
      Rails.logger.error "Error generating image: Image URL is nil. Response: #{response.body}"
      DEFAULT_IMAGE_URL
    else
      image_url
    end
  else
    Rails.logger.error "Error generating image: API request failed. Status: #{response.code}. Response: #{response.body}"
    DEFAULT_IMAGE_URL
  end
rescue StandardError => e
  Rails.logger.error "Error generating image: #{e.message}"
  DEFAULT_IMAGE_URL
  end
end