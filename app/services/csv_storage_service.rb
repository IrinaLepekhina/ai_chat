# app/services/csv_storage_service.rb

require 'csv'

class CsvStorageService < StorageService
  def initialize(csv_path)
    @csv_path = csv_path
  end

  def store_embedding(text, embedding)
    # Open the CSV file in append mode and store the text and embedding as a new row
    CSV.open(@csv_path, 'a') do |csv|
      csv << [text, embedding.to_json]
    end
  end

  def retrieve_embeddings(text = nil)
    # Read the embeddings from the CSV file
    embeddings = read_embeddings_from_csv
  
    if text
      # If a text is specified, filter the embeddings based on the text
      embeddings.select { |embedding| embedding['text'] == text }
    else
      # If no text is specified, return all embeddings
      embeddings
    end
  end

  def find_text_at_text_id(text_id)
    # Read the CSV file with headers and find the text at the specified text_id
    CSV.read(@csv_path, headers: true)[text_id]['text']
  end

  private

  def read_embeddings_from_csv
    embeddings = []
  
    # Iterate over each row in the CSV file
    CSV.foreach(@csv_path, headers: true) do |row|
      # Parse the embedding and text from the row and add it to the embeddings array
      embedding = {
        'embedding' => JSON.parse(row['embedding']),
        'text' => row['text']
      }
      embeddings << embedding
    end
  
    embeddings
  end
end
