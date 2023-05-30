#app/components/conversation_handling_component.rb

# Handles the processing of chat entries in a conversation using an AI integration component.
class ConversationHandlingComponent
  
  def initialize(ai_integration_component)
    @ai_integration_component = ai_integration_component
  end

  # Processes a chat entry in a conversation and generates a response using the AI integration component.
  #
  # @param conversation [Conversation] The conversation object.
  # @param content [String] The content of the chat entry.
  # @return [String] The generated response from the AI integration component.
  def process_chat_entry(conversation, content)
    response = @ai_integration_component.generate_ai_response(conversation, content)
    response
  end
end


# # Save AI response
# ai_response = AIResponse.create(conversation: conversation, response: response)