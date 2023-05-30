# app/controllers/api/v1/chat_entries_controller.rb

module Api
  module V1
    # Controller for handling chat entries in a conversation.
    class ChatEntriesController < ApiController
      
      # @return The response with the generated AI response and a success message.
      def create
        # Find the conversation
        @conversation = Conversation.find(params[:conversation_id])

        # Create a new chat entry with the conversation and message
        @chat_entry = @conversation.chat_entries.build(chat_entry_params)

        return unless @chat_entry.save!

        # Instantiate the ConversationHandlingComponent
        conversation_handler = ConversationHandlingComponent.new(AiIntegrationComponent.new)

        # Process user message and generate response
        @response = conversation_handler.process_chat_entry(@conversation, @chat_entry.content)

        # Render the response
        respond_to do |format|
          format.json { json_response({ response: @response, message: Message.record_created }, :created) }
        end
      end

      private

      def chat_entry_params
        params.require(:chat_entry).permit(:content)
      end
    end
  end
end