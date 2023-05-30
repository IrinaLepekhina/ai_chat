# app/controllers/conversations_controller.rb
module Api
  module V1
    # Controller for managing conversations.
    class ConversationsController < ApiController
      def index
        @conversations = Conversation.all

        render json: { conversations: @conversations }
      end
    
      def show
        @conversation = Conversation.find(params[:id])
        render json: { conversation: @conversation }
      end

      # POST /api/v1/conversations
      # @return The response with the generated AI response.
      def create
        # Create a new conversation
        @conversation = Conversation.new(conversation_params)

        return unless @conversation.save!
        
        # Instantiate the ConversationHandlingComponent
        conversation_handler = ConversationHandlingComponent.new(AiIntegrationComponent.new)
        
        # Process user message and generate response
        response_ai = conversation_handler.process_chat_entry(@conversation, params[:conversation][:message])
        
        # Render the response
        respond_to do |format|
          format.json { json_response({ response_ai: response_ai, message: Message.record_created }, :created) }
        end
      end

      private
      
      def conversation_params
        params.require(:conversation).permit(
          :user_id,
          chat_entries_attributes: [:content, :_destroy]
        )
      end
    end
  end
end