FactoryBot.define do
  factory :ai_response do
    content { "AI_Hello from factory" }
    original_text_id { "terms_of_conditions" }
    conversation { Conversation.all.sample.id }
    chat_entry { ChatEntry.all.sample.id }
    prompt { Prompt.all.sample.id }
  end
end
