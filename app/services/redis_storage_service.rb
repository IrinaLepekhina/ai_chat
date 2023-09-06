# app/services/redis_storage_service.rb

VECTOR_DIMENSIONS = 1536
NUM_TEXTS   = 3                                                                         # Number of texts to be vectorized from the text dir
TEXT_DIR    = Rails.env.test? ? 'spec/fixtures/public/texts/json' : 'public/texts/json' # directory of text files
VECTOR_FILE = Rails.env.test? ? 'spec/fixtures/test_vectors.json' : 'db/vectors.json'   # JSON file containing text ids and their embeddings

class RedisStorageService < StorageService
  include Loggable
  extend  Enumerize

  enumerize :object_type, in: [:HASH, :JSON], predicates: true
  enumerize :index_type,  in: [:FLAT, :HNSW], predicates: true
  enumerize :metric_type, in: [:L2, :IP, :COSINE], predicates: true
  enumerize :search_type, in: [:VECTOR, :HYBRID], predicates: true 

  def initialize(language_service = nil)
    log_info("Initializing RedisStorageService")
    @language_service = EmbeddingsAdapter.new(language_service)
    @redis = Redis.new(host: "#{ENV['REDIS_HOST']}", port: "#{ENV['REDIS_PORT']}".to_i)
    @object_type = :JSON
    @index_type  = :FLAT
    @metric_type = :COSINE
    @search_type = :VECTOR

    vectorize_texts
    load_db
    log_info("RedisStorageService initialized successfully")
  end

  def client
    @redis
  end

  def set_query(query_vector)
    log_info("Storing query vector in Redis")
    set_json_value('query_vector', '$', query_vector)
  end

  def store_embeddings(text_dict)
    client.pipelined do
      text_dict.each do |doc|
        set_json_value("doc:#{doc['text_id']}", '$', doc)
      end
    end
  end

  def retrieve_embeddings(text_id = nil)
    log_info("Retrieving embeddings from Redis for text_id: #{text_id}")
    
    if text_id
      # Retrieve a specific embedding by text_id
      embedding_json = client.call('JSON.GET', "doc:#{text_id}")
      embedding = JSON.parse(embedding_json)
      [embedding]
    else
      # Retrieve all embeddings
      keys = client.keys('doc:*')
      embeddings_json = client.call('JSON.MGET', *keys, '$') # '$.text_vector'
      embeddings = embeddings_json.map { |json| JSON.parse(json).first } # Extract the first array from each JSON
    end
  end
  
  def find_text_by_text_id(text_id)
    log_info("Finding text by text_id: #{text_id}")

    key = "doc:#{text_id}"
    text = client.call('JSON.GET', key)
    JSON.parse(text)['content']
  end

  private

  def set_json_value(key, path, value)
    client.call('JSON.SET', key, path, value.to_json)
  end

# vectorize_texts

  # Generates embeddings of texts and writes them to file
  def vectorize_texts
    log_info("Starting text embedding generation")

    return if vector_file_exists? || (!vector_file_exists? && directory_empty?)
  
    texts = get_text_files(NUM_TEXTS)
 
    # OpenAi entrance
    json_array = generate_emb_array(texts)
    write_to_json_file(json_array)
    log_info("Embeddings generated successfully")
  end

  def vector_file_exists?
    File.exist?(VECTOR_FILE)
  end

  def directory_empty?
    unless Dir.exist?(TEXT_DIR)
      raise(ExceptionHandler::TextDirectoryEmptyError, "Text directory '#{TEXT_DIR}' not found.")
    end
  end

  def get_text_files(limit)
    text_files = Dir.entries(TEXT_DIR).reject { |f| File.directory?(f) }.first(limit)
    text_files.map do |file|
      file_path = "#{TEXT_DIR}/#{file}"
      file_extension = File.extname(file)
      content = File.read(file_path)

      if file_extension == '.json'
        parsed_content = JSON.parse(content)
      elsif file_extension == '.txt'
        { text_id: File.basename(file, '.*'), content: content }
      else
        nil
      end
    end.compact
  end
  
  # OpenAi entrance
  def generate_emb_array(texts)
    texts.map do |text|
      vector = @language_service.get_embeddings(text['content'])
      text['text_vector'] = vector
      text
    end
  end    

  def write_to_json_file(json_array)
    File.open(VECTOR_FILE, 'w') do |outfile|
      outfile.puts(json_array.to_json)
    end
  end
  
# load_db

  # Loads Redis with JSON documents containing text embeddings.
  # Creates an index containing a text_vector field for the embedding
  # and a user-specified field for the text_id.
  def load_db
    log_info("Loading text embeddings into Redis database")

    delete_text_keys
    text_dict = get_texts(VECTOR_FILE)
    store_embeddings(text_dict)
    create_index
    log_info("Redis database load successful")
  end

  def delete_text_keys
    text_keys = client.keys('doc:*')
    client.del(*text_keys) unless text_keys.empty?
  end

  def get_texts(vector_file)
    """ Fetches text embeddings from a pre-made vector file
        Returns
        -------
        dictionary of text ids and their associated vectors
    """
    file_content = JSON.parse(File.read(vector_file))
  end

  def create_index
    begin
      client.call('FT.INFO', 'text_idx')
      puts 'Index already exists!'
    rescue Redis::CommandError => e
      if e.message.include?('Unknown Index name')
        schema = generate_schema
        begin
          client.call('FT.CREATE', 'text_idx', 'ON', @object_type, 'PREFIX', '1', 'doc:', 'SCHEMA', *schema)
        rescue Redis::CommandError => e
          handle_index_creation_error(e)
        end
      end
    end
  end
  
  def generate_schema
    [
      '$.text_id', 'AS', 'text_id', 'TEXT',
      '$.content', 'AS', 'content', 'TEXT',
      '$.text_vector', 'AS', 'text_vector', @search_type, @index_type, '6',
      'TYPE', 'FLOAT32', 'DIM', VECTOR_DIMENSIONS,
      'DISTANCE_METRIC', @metric_type
    ] 
  end

  def handle_index_creation_error(error)
    log_error("Error creating index: #{error.message}")
    if error.message == 'Index already exists'
      log_info("Index exists already, skipped creation.")
    else
      exit(1)
    end
  end
end