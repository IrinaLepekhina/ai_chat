class StorageService
  include Loggable # Include the Loggable module

  # Store the embeddings of the given text_dict.
  # @param [Hash] text_dict The dictionary containing the embeddings and other related information.
  # @raise [NotImplementedError] if the method is not implemented by the subclass.
  def store_embeddings(text_dict)
    log_info("Attempt to store embeddings in StorageService base class.")
    raise NotImplementedError, 'Subclasses must implement the store_embeddings method'
  end

  # Retrieve the embeddings based on the given text_id.
  # @param [String] text_id The ID associated with the embeddings.
  # @raise [NotImplementedError] if the method is not implemented by the subclass.
  # @return [Hash] the retrieved embeddings.
  def retrieve_embeddings(text_id = nil)
    log_info("Attempt to retrieve embeddings with text_id: #{text_id} in StorageService base class.")
    raise NotImplementedError, 'Subclasses must implement the retrieve_embeddings method'
  end

  # Find the text associated with the given text_id.
  # @param [String] text_id The ID of the text to be found.
  # @raise [NotImplementedError] if the method is not implemented by the subclass.
  # @return [String] the found text.
  def find_text_by_text_id(text_id)
    log_info("Attempt to find text by text_id: #{text_id} in StorageService base class.")
    raise NotImplementedError, 'Subclasses must implement the find_text_by_text_id method'
  end
end
