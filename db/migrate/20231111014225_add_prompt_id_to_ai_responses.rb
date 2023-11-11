class AddPromptIdToAiResponses < ActiveRecord::Migration[7.0]
  def change
    add_column :ai_responses, :prompt_id, :bigint
    add_index  :ai_responses, :prompt_id
  end
end
