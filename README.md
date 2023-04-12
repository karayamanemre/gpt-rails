# openai-rails

- This is a web application that allows users to generate a DALL-E image based on a given prompt. The application uses OpenAI's GPT-3 language model to generate a text response to the prompt, and then uses that response as an input to generate an image using OpenAI's DALL-E image generation API. The application is built using the Ruby on Rails framework and includes a user interface that allows users to enter a prompt, generate an image based on that prompt, and view the resulting image along with the text response. The application requires an OpenAI API key, which must be provided by the user in order to use the application.

## Installation

1. Clone the repository:

```bash
git clone https://github.com/karayamanemre/gpt-rails.git
```

2. Install the required gems:

```bash
bundle install
```

3. Create a .env file in the root directory of the project and add your OpenAI API key:

```bash
OPENAI_API_KEY=your-api-key
```

4. Start the Rails server:

```bash
rails server
```

5. Visit http://localhost:3000 in your web browser to see the app in action.

## Usage

1. Type some text into the input field on the home page and click "Generate".
2. Wait for the text and images to be generated.
3. Use the left and right arrows to navigate through the generated images.
4. Click "Copy Text" to copy the generated text to your clipboard.
