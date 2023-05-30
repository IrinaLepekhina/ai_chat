class CreateChatEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :chat_entries do |t|
      t.references :conversation, null: false, foreign_key: true
      t.text :content
      t.datetime :sent_at

      t.timestamps
    end
  end
end
