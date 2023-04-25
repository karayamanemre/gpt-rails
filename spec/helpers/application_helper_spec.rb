require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#generate_response' do
    let(:prompt) { 'Generate a response for this test.' }
    let(:api_key) { 'your_api_key' }
    let(:response_body) do
      {
        'choices' => [
          {
            'message' => {
              'content' => 'This is a test response from GPT-3.5-turbo.'
            }
          }
        ]
      }.to_json
    end

    before do
      stub_request(:post, "https://api.openai.com/v1/chat/completions")
        .with(
          body: {
            'model' => 'gpt-3.5-turbo',
            'messages' => [
              { 'role' => 'system', 'content' => 'You are a helpful assistant.' },
              { 'role' => 'user', 'content' => prompt }
            ],
            'max_tokens' => 2000
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => /^Bearer .*/
          }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the generated response from the API' do
      response = helper.generate_response(prompt)
      expect(response).to eq('This is a test response from GPT-3.5-turbo.')
    end
  end
end
