require 'net/http'
require 'uri'
require 'json'

DEFAULT_IMAGE_URL = 'https://via.placeholder.com/480x480?text=Image+Not+Available'


module ApplicationHelper
  def generate_response(prompt)
    api_key = ENV.fetch("OPENAI_API_KEY")
    endpoint = "https://api.openai.com/v1/chat/completions"

    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{api_key}"
    }
    body = {
      'model' => 'gpt-3.5-turbo',
      'messages' => [{ 'role' => 'system', 'content' => 'You are a helpful assistant.' }, { 'role' => 'user', 'content' => prompt }],
      'max_tokens' => 2000
    }.to_json

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      text = parsed_response["choices"][0]["message"]["content"]
    else
      raise "Error generating response: API request failed. Status: #{response.code}. Response: #{response.body}"
    end
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
      'num_images' => 1,
      'size' => size,
      'response_format' => 'url'
    }.to_json

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      image_url = parsed_response["data"][0]["url"]
      if image_url.nil?
        Rails.logger.error "Error generating image: Image URL is nil. Response: #{response.body}"
        DEFAULT_IMAGE_URL
      else
        Rails.logger.info "Generated image URL: #{image_url}"
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


  def generate_image_description(text)
    prompt = "Create a DALL-E image prompt for the following text: '#{text}'"
    image_description = generate_response(prompt)
    image_description.strip
  end

  def save_image_locally(image_url, filename)
    uri = URI.parse(image_url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      File.open(Rails.root.join('public', 'images', 'generated', filename), 'wb') do |file|
        file.write(response.body)
      end
      "/images/generated/#{filename}"
    else
      Rails.logger.error "Error saving image: HTTP request failed. Status: #{response.code}. Response: #{response.body}"
      DEFAULT_IMAGE_URL
    end
  rescue StandardError => e
    Rails.logger.error "Error saving image: #{e.message}"
    DEFAULT_IMAGE_URL
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