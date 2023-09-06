#### Ruby on Rails Conversational Order Assistant with Docker

The application offers JSON and HTML support for various functionalities:

- ChatEntriesController: Manages requests related to user's questions, including endpoints for creating chat entries and processing them to obtain company information based on OpenAI-generated responses.
- ProductsController: Manages requests related to products, including endpoints for creating, listing, and retrieving products.
- UsersController: Handles user signup requests.
- AuthenticationController: Manages user authentication.

For HTML requests, the application sets the JWT token as a signed cookie.   
For JSON requests, the application sets the JWT token in the Authorization header using Bearer authentication.

#### Infrastructure and Services:

##### - Dialog Component
Manages the processing of chat entries within a conversation.  
Generates AI responses associated with chat entries and updates the entries to reference the AI responses.

##### - AI Integration Component
Allows integration with AI services.  
Utilizes the ConversationAiHandler, OpenAiService and RedisStorageService classes to generate AI responses based on conversations and content.

##### - Conversation Ai Handler
Handles AI-based conversation processing.  
Generates an AI response based on the provided content.

##### - Open Ai Service
Interacts with the OpenAI API for AI responses and text embeddings.

##### - Redis Storage Service
Stores, retrieves, and manages text embeddings within Redis.   
Facilitates index management, enhancing vector similarity searches.

#####  - Redis-Powered Vector Similarity Service
Uses Redis for similarity calculations.  
Determines the similarity between a question embedding and text embeddings, aiding in identifying the closest matching text.

#### Installation:
##### Clone the repository

`$ git clone https://github.com/IrinaLepekhina/planta_chat.git`

`$ cd planta_chat`


##### Create the .env file with the necessary environment variables
`$ cp .env.sample .env`


##### Add your private keys

`$ echo "OPENAI_API_KEY='replace_with_your_key'" >> .env`

`$ echo "BOXSTORE_API_KEY='replace_with_your_key'" >> .env`

##### Create network and start the containers

`$ docker network create shared_network`

`$ docker compose -f docker-stack-git.yml up -d`

##### Run the tests

`$ docker compose exec web bin/rspec`


##### Configuration

The Dockerfile installs the necessary dependencies, including Ruby, Node.js, Yarn, Redis, PostgreSQL.  
The credentials can be set using environment variables.  
The docker-compose.yml file configures multiple services: the web application, Redis, PostgreSQL and SeleniumChrome for test with Capybara. It also includes volume mappings for persisting data across containers.