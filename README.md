#### Ruby on Rails Web Application with Docker

This is a simple Ruby on Rails web application that includes a Dockerfile for easy deployment. It includes a MealsController that handles JSON and HTML requests related to meals, with endpoints for creating, listing, and retrieving meals.

#### Installation:
##### Clone the repository

`$ git clone https://github.com/IrinaLepekhina/menu_doc.git`

`$ cd menu_doc`


##### Create the .env file with the necessary environment variables

`$ echo "POSTGRES_USER='postgres'" > .env`

`$ echo "POSTGRES_PASSWORD='long_and_secure_password'" >> .env`

`$ echo "POSTGRES_DB='menu_doc_development'" >> .env`

`$ echo "DATABASE_HOST='database'" >> .env`


##### Start the containers

- this way

`$ docker compose -f docker-stack.yml up -d`

- or another simular result way

`$ docker pull ghcr.io/irinalepekhina/menu_web:prod`

`$ docker compose -f docker-stack-git.yml up -d`

##### Create the database and run migrations

`$ docker compose exec web bin/rails db:create`

`$ docker compose exec web bin/rails db:migrate`

`$ docker compose exec web bin/rails db:migrate RAILS_ENV=test`


##### Run the tests

`$ docker compose exec web bin/rspec`


##### Configuration

The Dockerfile installs the necessary dependencies for the application, including Ruby, Node.js, Yarn, Redis, and PostgreSQL.
The application is configured to use PostgreSQL as the database, and the database credentials can be set using environment variables.
The application includes a docker-compose.yml file for configuring multiple services, including the web application, Redis, and PostgreSQL.
This file also includes volume mappings for persisting data across containers.