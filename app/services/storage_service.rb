# app/services/storage_service.rb

# The StorageService class provides a base implementation for storing and retrieving embeddings.
# Subclasses must implement specific behavior for storing embeddings, retrieving embeddings, and finding text at an index.
class StorageService
  def store_embedding(text, embedding)
    raise NotImplementedError, 'Subclasses must implement the store_embedding method'
  end

  def retrieve_embeddings
    raise NotImplementedError, 'Subclasses must implement the retrieve_embeddings method'
  end

  def find_text_at_index(index)
    raise NotImplementedError, 'Subclasses must implement the find_text_at_index method'
  end
end
