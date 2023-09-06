# app/controllers/api/v1/conversations_controller.rb

module Api
  module V1
    class ConversationsController < ApiController
      include Loggable
      
      skip_before_action :verify_authenticity_token, only: [:create]

      def create
        if params[:conversation_id]
          @conversation = Conversation.find_or_create_by!(id: params[:conversation_id]) do |conv|
            conv.user_id = current_user&.id
          end
          log_info("Found or created conversation", conversation_id: @conversation.id)
        else
          @conversation = Conversation.create!(user_id: current_user&.id)
          log_info("Created new conversation", conversation_id: @conversation.id)
        end
   
        respond_to do |format|
          format.html { redirect_to api_conversation_url(@conversation) }
          format.json { json_response(@conversation, :created) }
        end
      end

      def show
        @conversation     = Conversation.find(params[:id])
        @chat_entry       = @conversation.chat_entries.build
        @chat_entries     = @conversation.chat_entries.order(created_at: :asc).page(params[:page]).per(4)

        last_chat_entry = @chat_entries.last
        if last_chat_entry && last_chat_entry.ai_response
          @original_text_id = last_chat_entry.ai_response.original_text_id
        end

        log_info("Showing conversation", conversation_id: @conversation.id)
        respond_to do |format|
          format.html { render :show }
          format.json { json_response(@conversation, :found) }
        end
      end

      def index
        @conversations = Conversation.page(params[:page]).per(10)
        
        log_info("Listing conversations")
        respond_to do |format|
          format.html
          format.json { json_response(@conversations, :found) }
        end
      end

      def destroy
        @conversation = Conversation.find(params[:id])

        if @conversation.destroy
          log_info("Conversation destroyed", conversation_id: @conversation.id)
          respond_to do |format|
            format.html { redirect_to api_conversations_url, notice: 'Conversation deleted' }
            format.json { render json: 'Conversation deleted'}
          end
        else
          log_error("Error destroying conversation", conversation_id: @conversation.id)
          redirect_to api_conversation_url(@conversation), notice: "Cannot delete conversation"
        end
      end

      private

      def conversation_params
        params.require(:conversation).permit(:conversation_id)
      end
    end
  end
end