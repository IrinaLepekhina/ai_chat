# Controller for handling API requests related to meals.
#
# Includes endpoints for creating, listing, and retrieving meals.
# Implements basic CRUD operations using JSON and HTML formats.
#
# Uses the following modules:
# - Exceptionable: Defines custom error subclasses and handlers.
# - Response: Defines a helper method for generating JSON responses.
#
# Controller-specific custom error messages are defined in the `Message` class.
#
# @see Exceptionable
# @see Response
# @see Message

module Api
  module V1
    class MealsController < ApiController
      # http_basic_authenticate_with name: 'user25@email', password: 'qwerty'

      # GET /api/meals
      # GET /api/meals.json
      # GET /api/meals.html
      def index
        @meals = Meal.all

        respond_to do |format|
          format.html
          format.json { json_response(@meals, :ok) }
        end
      end

      # GET /api/meals/1
      # GET /api/meals/1.json
      # GET /api/meals/1.html
      # raise Excaptionable::RecordNotFound, Message.not_found, status::redirected
      def show
        @meal = Meal.find(params[:id])
        respond_to do |format|
          format.html
          format.json { json_response(@meal, :found) }
        end
      end

      #GET /api/meals/new
      #GET /api/meals/new.html
      def new
        @meal = Meal.new
      end

      # POST /api/meals
      # POST /api/meals.json
      # POST /api/meals.html
      # raise Excaptionable::RecordInvalid, Message.invalid, status: :unprocessable_entity)
      def create
        @meal = Meal.new(meal_params)

        return unless @meal.save!
        respond_to do |format|
          format.html { redirect_to api_meal_url(@meal), notice: Message.record_created }
          format.json { json_response({ meal: @meal, message: Message.record_created }, :created) }
        end
      end

      private

      def meal_params
        params.require(:meal).permit(
          :title,
          :price_type,
          :description,
          :price_init
        )
      end
    end
  end
end
