class AddAiResponseReferenceToChatEntries < ActiveRecord::Migration[7.0]
  def change
    add_reference :chat_entries, :ai_response, null: true, foreign_key: true
  end
end