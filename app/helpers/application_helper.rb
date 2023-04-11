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
    response = openai.Image.create(parameters: {prompt: "Post-apocalyptic city view", size: "480x480"})
    response.dig("data", 0, "url")
  end
end
