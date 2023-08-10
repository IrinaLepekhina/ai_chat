# Controller for handling API requests related to products.
#
# Includes endpoints for creating, listing, and retrieving products.
# Implements basic CRUD operations using JSON and HTML formats.
#
# Uses the following modules:
# - ExceptionHandler: Defines custom error subclasses and handlers.
# - Response: Defines a helper method for generating JSON responses.
#
# Controller-specific custom error messages are defined in the `Message` class.
#
# @see ExceptionHandler
# @see Response
# @see Message

module Api
  module V1
    class ProductsController < ApiController

      def index
        @products = Product.page(params[:page]).per(10)

        respond_to do |format|
          format.html
          format.json { json_response(@products, :ok) }
        end
      end

      # raise Excaptionable::RecordNotFound, Message.not_found, status::redirected
      def show
        @product = Product.find(params[:id])
        respond_to do |format|
          format.html
          format.json { json_response(@product, :found) }
        end
      end

      def new
        @product = Product.new
      end

      # raise Excaptionable::RecordInvalid, Message.invalid, status: :unprocessable_entity)
      def create
        @product = Product.new(product_params)

        return unless @product.save!
        respond_to do |format|
          format.html { redirect_to api_product_url(@product), notice: Message.record_created }
          format.json { json_response({ product: @product, message: Message.record_created }, :created) }
        end
      end

      private

      def product_params
        params.require(:product).permit(
          :title,
          :price_type,
          :description,
          :price_init
        )
      end
    end
  end
end
