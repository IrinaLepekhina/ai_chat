#app/components/conversation_handling_component.rb

# Handles the processing of chat entries in a conversation using an AI integration component.
class ConversationHandlingComponent
  
  def initialize(ai_integration_component)
    @ai_integration_component = ai_integration_component
  end

  def process_chat_entry(conversation, content)
    # Check if the content is blank
    if content.blank?
      return "How can I help you?"
    else
      # Generate an AI response using the AI integration component
      response = @ai_integration_component.generate_ai_response(conversation, content)
      return response
    end
  end
end