# app/controllers/api/v1/chat_entries_controller.rb

module Api
  module V1
    class ChatEntriesController < ApiController
      skip_before_action :verify_authenticity_token, only: [:create]

      def create
        log_info("Processing chat entry creation", conversation_id: params[:conversation_id])

        @conversation = Conversation.find(params[:conversation_id])
        # @conversation = Conversation.find_by(id: params[:conversation_id])
        
        @chat_entry = @conversation.chat_entries.new(chat_entry_params)

        return unless @chat_entry.save!
        log_info("chat_entry saved successfully", chat_entry_id: @chat_entry.id)

        dialog_component = DialogComponent.new
        dialog_component.process_chat_entry(@conversation, @chat_entry)
        log_info("Processed chat entry with DialogComponent")

        respond_to do |format|
          format.html { redirect_to api_conversation_path(@conversation) }
          format.json { json_response(@chat_entry, :created) }
        end
      end

      private

      def chat_entry_params
        params.require(:chat_entry).permit(:content)
      end
    end
  end
end