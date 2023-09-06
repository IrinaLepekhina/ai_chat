# app/services/vector_simularity_service.rb

class VectorSimularityService
  include Loggable

  TOPK    = 5     # Number of results to be returned from the VSS query
  DIALECT = 2
  
  def initialize(redis_service)
    @redis_service = redis_service
  end

  def query_original_text(question_embedding)
    log_info("Querying original text with given embedding.")
    # Calculate the similarity between the question embedding and each text embedding
    similarity_array = query(question_embedding)
    
    # Find the closest text
    find_max_similarity(similarity_array)
  end

  private

  def query(question_embedding)
    log_info("Executing query for similarity.")
    if question_embedding.empty?
      log_error("Question embedding is empty.")
      # Return an empty result if the question embedding is empty
      return []
    end

    blob = encode_vector(question_embedding)
    params = ['BLOB', blob]
    query = generate_query
    execute_search(query, params)
  end

  def find_max_similarity(similarity_array)
    closest_distance = similarity_array
      .select { |element| element.is_a?(Array) && element[0] == "distance" }
      .min_by { |element| element[1].to_f }

    if closest_distance
      measure, score, path, json_data = closest_distance
      element_hash = JSON.parse(json_data)
      {
        text: element_hash['content'],
        text_id: element_hash['text_id']
      }
    else
      { text: nil, text_id: nil }
    end
  end
    
  def encode_vector(vector)
    vector.pack('e*')
  end

  def generate_query
    "*=>[KNN #{TOPK} @text_vector $BLOB AS distance]"
  end

  def execute_search(query, params)
    result = @redis_service.client.call('FT.SEARCH', 'text_idx', query, 'PARAMS', 6,  *params, TOPK, 10, 'SORTBY', 'distance', 'DIALECT', DIALECT)
  end
end