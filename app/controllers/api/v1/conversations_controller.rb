# app/controllers/api/v1/conversations_controller.rb

module Api
  module V1
    # Controller for managing conversations.
    class ConversationsController < ApiController
      def create
        @conversation = Conversation.create(user_id: current_user.id)

        respond_to do |format|
          format.html { redirect_to api_conversation_url(@conversation) }
          format.json { json_response( @conversation, :created) }
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

        respond_to do |format|
          format.html { render :show }
          format.json { json_response( @conversation, :found) }
        end
      end

      def index
        @conversations = Conversation.page(params[:page]).per(10)

        respond_to do |format|
          format.html
          format.json { json_response( @conversations, :found ) }
        end
      end

      def destroy
        @conversation = Conversation.find(params[:id])
    
        if @conversation.destroy
          respond_to do |format|
            format.html { redirect_to api_conversations_url, notice: 'Conversation has been destroyed' }
            format.json { render json: 'Conversation has been destroyed'}
          end
        else
          redirect_to api_conversation_url(@conversation), notice: "Cannot delete conversation"
        end
      end
    end
  end
end