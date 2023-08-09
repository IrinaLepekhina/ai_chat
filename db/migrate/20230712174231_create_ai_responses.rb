class CreateAiResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_responses do |t|
      t.text :content
      t.text :original_text_id
      t.references :conversation, foreign_key: true
      t.references :chat_entry, foreign_key: true

      t.timestamps
    end
  end
end
