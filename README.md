#### Ruby on Rails Web Application with Docker

This is a simple Ruby on Rails web application that includes a Dockerfile for easy deployment. It includes JSON and HTML support for:
- ProductsController that handles requests related to products, with endpoints for creating, listing, and retrieving products.
- UsersController that handles requests related to user signup.
- AuthenticationController that handles user authentication.


For HTML requests, the application sets the JWT token as a signed cookie.
For JSON requests, the application sets the JWT token in the response header.

#### Installation:
##### Clone the repository

`$ git clone https://github.com/IrinaLepekhina/planta_chat.git'

`$ cd planta_chat`


##### Create the .env file with the necessary environment variables

`$ echo "POSTGRES_USER='postgres'" > .env`

`$ echo "POSTGRES_PASSWORD='long_and_secure_password'" >> .env`

`$ echo "POSTGRES_DB='planta_doc_development'" >> .env`

`$ echo "DATABASE_HOST='database'" >> .env`


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