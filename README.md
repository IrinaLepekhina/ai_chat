#### Ruby on Rails Web Application with Docker

This is a simple Ruby on Rails web application that includes a Dockerfile for easy deployment. It includes JSON and HTML support for:
- ProductsController that handles requests related to products, with endpoints for creating, listing, and retrieving products.
- UsersController that handles requests related to user signup.
- AuthenticationController that handles user authentication.


For HTML requests, the application sets the JWT token as a signed cookie.
For JSON requests, the application sets the JWT token in the response header.

##### AI Integration Component
A new AI Integration Component has been added to the application, allowing integration with AI services. It utilizes the ConversationAiHandler and OpenAiService classes to generate AI responses based on conversations and content.

- AiIntegrationComponent: Provides integration with AI services.
- ConversationAiHandler: Handles AI-based conversation processing.
- OpenAiService: Interacts with the OpenAI API for AI responses and text embeddings.

##### CsvStorageService
The CsvStorageService is a service class that encapsulates the functionality to store and retrieve embeddings in a CSV file, extending the StorageService class. It provides an encapsulated and modular approach to handle storage operations, allowing flexibility to switch to different storage mechanisms in the future.

#### Installation:
##### Clone the repository

`$ git clone https://github.com/IrinaLepekhina/planta_chat.git`

`$ cd planta_chat`


##### Create the .env file with the necessary environment variables

`$ echo "POSTGRES_USER='postgres'" > .env`

`$ echo "POSTGRES_PASSWORD='long_and_secure_password'" >> .env`

`$ echo "POSTGRES_DB='planta_doc_development'" >> .env`

`$ echo "DATABASE_HOST='database'" >> .env`

`$ echo "OPENAI_API_KEY='replace_with_your_key'" >> .env`


##### Start the containers

`$ docker compose -f docker-stack-git.yml up -d`

##### Create the database and run migrations

`$ docker compose exec web bin/rails db:create`

`$ docker compose exec web bin/rails db:migrate`

`$ docker compose exec web bin/rails db:migrate RAILS_ENV=test`


##### Run the tests

`$ docker compose exec web bin/rspec`


##### Configuration

The Dockerfile installs the necessary dependencies for the application, including Ruby, Node.js, Yarn, Redis, PostgreSQL.
The application is configured to use PostgreSQL as the database, and the database credentials can be set using environment variables.
The application includes a docker-compose.yml file for configuring multiple services, including the web application, Redis, PostgreSQL and SeleniumChrome for test with Capybara.
This file also includes volume mappings for persisting data across containers.