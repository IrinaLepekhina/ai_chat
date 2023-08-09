# app/controllers/api/v1/chat_entries_controller.rb

module Api
  module V1
    # Controller for handling chat entries in a conversation.
    class ChatEntriesController < ApiController
      
      def create
        @conversation = Conversation.find(params[:conversation_id])
        @chat_entry = @conversation.chat_entries.new(chat_entry_params)
        
        return unless @chat_entry.save!

        dialog_component = DialogComponent.new
        dialog_component.process_chat_entry(@conversation, @chat_entry)

        respond_to do |format|
          format.html { redirect_to api_conversation_path(@conversation) }
          format.json { json_response( @chat_entry, :created) }
        end
      end

      private

      def chat_entry_params
        params.require(:chat_entry).permit(:content)
      end
    end
  end
end