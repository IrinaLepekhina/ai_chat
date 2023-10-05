require 'rails_helper'

RSpec.describe RedisStorageService, type: :service do
  let(:mock_redis) { instance_double("Redis") }
  let(:mock_language_service) { instance_double("LanguageService") }
  let(:vector_file_path) { 'spec/fixtures/test_vectors.json' }

  subject { described_class.new(language_service: mock_language_service, redis_client: mock_redis) }

  before do
    allow(mock_redis).to receive(:call).and_return(nil)
    allow(mock_redis).to receive(:pipelined).and_yield
    allow(mock_redis).to receive(:keys).and_return([])

    allow(mock_language_service).to receive(:get_embeddings).with(instance_of(String)).and_return([1.0, 2.0])
  end

  shared_examples_for "an index creator" do
    it 'creates an index' do
      calls_to_redis = []
      allow(mock_redis).to receive(:call) { |*args| calls_to_redis << args }
    
      subject.load_db
      
      expect(calls_to_redis.any? { |args| args.include?('FT.CREATE') }).to be(true)
    end
  end

  describe '#load_db' do
    context 'when the database is not loaded' do
      before do
        # allow(mock_redis).to receive(:keys).with('doc:*').and_return([])
        allow(File).to receive(:read).with(vector_file_path).and_return('[{"text_id":"1234", "content":"Sample text"}]')
        # allow(mock_redis).to receive(:call).with('FT._LIST').and_return([])
      end

      it_behaves_like "an index creator"
      
      it 'loads text embeddings into Redis database' do
        expect(mock_redis).to receive(:pipelined).and_yield
        expect(mock_redis).to receive(:call).with('JSON.SET', 'doc:1234', '$', '{"text_id":"1234","content":"Sample text"}')
        subject.load_db
      end
    end

    context 'when the database is loaded but the index is missing' do
      before do
        # allow(mock_redis).to receive(:keys).with('doc:*').and_return(['doc:1234'])
        # allow(mock_redis).to receive(:call).with('FT._LIST').and_return([])
      end

      it_behaves_like "an index creator"
    end

    context 'when both the database and index are loaded' do
      before do
        allow(mock_redis).to receive(:keys).with('doc:*').and_return(['doc:1234'])
        # allow(mock_redis).to receive(:call).with('FT._LIST').and_return(['text_idx'])
      end

      it 'does not store embeddings again' do
        expect(mock_redis).not_to receive(:pipelined)
        subject.load_db
      end

      it 'does not create the index again' do
        expect(mock_redis).not_to receive(:call).with(include('FT.CREATE', 'text_idx'))
        subject.load_db
      end
    end
  end

  describe '#create_index' do
    let(:some_data) { ['index1', 'index2'] } # Example data

    context 'when the index does not exist' do
      before do
        allow(mock_redis).to receive(:call).with('FT.INFO', 'text_idx').and_raise(Redis::CommandError)
      end

      it 'creates an index' do
        calls_to_redis = []
        allow(mock_redis).to receive(:call) { |*args| calls_to_redis << args }
      
        subject.load_db
        
        expect(calls_to_redis.any? { |args| args.include?('FT.CREATE') }).to be(true)
      end        
    end

    context 'when the index exists' do
      before do
        allow(subject).to receive(:index_exists?).with('text_idx').and_return(true)
      end
    
      it 'skips the creation of index' do
        expect(subject).not_to receive(:create_index)
        subject.load_db
      end
    end
  end

  describe '#vectorize_texts' do
    let(:generated_emb_array) { [[1.0, 2.0], [3.0, 4.0]] }
    let(:vector) { [1.0, 2.0] }
    let(:vector_file_content) { [] }
    let(:language_service) { instance_double("EmbeddingsAdapter") }
    let(:sample_texts) do
      [
        "By using our products, you agree to this, and we are obliged to comply with that.",
        "Planta is a company that produces products and has a PlantaChat - a Conversational Order Assistant, ... facilitating conversation-based order placement, providing information, and enhancing user engagement.",
        "How can I get my products?\nOrdering: Let's talk and create an order.\nIn-store: Come visit our factory ... 2 PM will be delivered promptly.\nNo worries if you order after 12 PM; we'll still deliver quickly."
      ]
    end
    

    before do
      allow(File).to receive(:exist?).and_return(false) # default value
      allow(File).to receive(:exist?).with(vector_file_path).and_return(false)

      allow(subject).to receive(:vector_file_exists?).and_return(false) 
      allow(subject).to receive(:directory_empty?).and_return(false) 
      allow(subject).to receive(:get_text_files).and_return(sample_texts)
      allow(subject).to receive(:generate_emb_array).and_return(generated_emb_array)
      allow(subject).to receive(:write_to_json_file) do |file_path, content|
        vector_file_content.concat(content)
      end
      allow(EmbeddingsAdapter).to receive(:new).and_return(language_service)
    end

    context 'when the vector file does not exist' do
      before do
        # Ensure the vector file does not exist initially
        allow(File).to receive(:exist?).with(vector_file_path).and_return(false)
        subject.vectorize_texts
      end

      it 'creates the vector file' do
        expect(subject).to have_received(:write_to_json_file).with(generated_emb_array)
      end
 
      it 'vectorizes texts using the language service' do
        expect(mock_language_service).to have_received(:get_embeddings).exactly(sample_texts.length).times
      end
    end

    context 'when the vector file already exists' do
      before do
        allow(subject).to receive(:vector_file_exists?).and_return(true)
      end

      it 'exits early without vectorizing the texts' do
        subject.vectorize_texts

        expect(subject).not_to have_received(:directory_empty?)
        expect(subject).not_to have_received(:get_text_files)
        expect(subject).not_to have_received(:generate_emb_array)
        expect(subject).not_to have_received(:write_to_json_file)
      end
    end

    context 'when the vector file does not exist and directory is empty' do
      before do
        allow(subject).to receive(:vector_file_exists?).and_return(false)
        allow(subject).to receive(:directory_empty?).and_return(true)
      end

      it 'exits early without vectorizing the texts' do
        subject.vectorize_texts

        expect(subject).to have_received(:directory_empty?).once # Ensure it's called once
        expect(subject).not_to have_received(:get_text_files) # Should not be called
        expect(subject).not_to have_received(:generate_emb_array) # Should not be called
        expect(subject).not_to have_received(:write_to_json_file) # Should not be called
      end
    end
  end

  describe '#initialize' do
    it 'initializes the service with the required variables' do
      expect(subject.client).to eq(mock_redis)
      expect(subject.instance_variable_get(:@language_service)).to eq(mock_language_service)
    end
  end

  describe '#store_embeddings' do
    let(:text_dict) { [{ 'text_id' => '1', 'content' => 'sample' }] }

    it 'stores the embeddings into the redis database' do
      expect(mock_redis).to receive(:pipelined)
      subject.store_embeddings(text_dict)
    end
  end
 
  describe "#retrieve_embeddings" do
    let(:text1) { {'text_id' => 'text1', 'content' => 'This is text 1', 'text_vector' => [0.1, 0.2, 0.3] }.to_json }

    context 'when text_id is provided' do
      it 'retrieves the specific embedding' do
        allow(mock_redis).to receive(:call).with('JSON.GET', 'doc:1').and_return(text1)
        result = subject.retrieve_embeddings('1')
        expect(result.size).to eq(1)
        expect(result.first).to eq(JSON.parse(text1))
      end
    end

    context 'when text_id is not provided' do
      it 'retrieves all embeddings' do
        allow(mock_redis).to receive(:keys).and_return(['doc:1'])
        allow(mock_redis).to receive(:call).with('JSON.MGET', 'doc:1', '$').and_return([{ 'content' => 'sample' }.to_json])

        
        result = subject.retrieve_embeddings
        expect(result).to eq([["content", "sample"]])
      end
    end
  end
end

