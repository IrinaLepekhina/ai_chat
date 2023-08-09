# app/services/storage_service.rb

# The StorageService class provides a base implementation for storing and retrieving embeddings.
# Subclasses must implement specific behavior for storing embeddings, retrieving embeddings, and finding text at an text_id.
class StorageService
  def store_embeddings(text_dict)
    raise NotImplementedError, 'Subclasses must implement the store_embeddings method'
  end

  def retrieve_embeddings(text_id = nil)
    raise NotImplementedError, 'Subclasses must implement the retrieve_embeddings method'
  end

  def find_text_by_text_id(text_id)
    raise NotImplementedError, 'Subclasses must implement the find_text_by_text_id method'
  end
end
