FactoryBot.define do
  factory :chat_entry do
    conversation { Conversation.all.sample.id }
    content { "Hello" }
  end
end
