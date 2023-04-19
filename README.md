Ruby on Rails Web Application with Docker

This is a simple Ruby on Rails web application that includes a Dockerfile for easy deployment. It includes a MealsController that handles JSON and HTML requests related to meals, with endpoints for creating, listing, and retrieving meals.

Installation:
docker compose -f docker-stack.yml up -d

docker compose exec web bin/rails db:migrate

Usage:
docker compose exec web bin/rspec

Configuration
The Dockerfile installs the necessary dependencies for the application, including Ruby, Node.js, Yarn, Redis, and PostgreSQL. The application is configured to use PostgreSQL as the database, and the database credentials can be set using environment variables.

The application includes a docker-compose.yml file for configuring multiple services, including the web application, Redis, and PostgreSQL. This file also includes volume mappings for persisting data across containers.