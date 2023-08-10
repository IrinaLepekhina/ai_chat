FactoryBot.define do
  factory :chat_entry do
    conversation { Conversation.all.sample.id }
    content { "list your terms of conditions?" }
  end
end
