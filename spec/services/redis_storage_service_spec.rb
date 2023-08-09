# spec/services/redis_storage_service_spec.rb

require 'rails_helper'

describe RedisStorageService, type: :service do
  let(:language_service) { instance_double('EmbeddingsAdapter') }
  let(:service)          { RedisStorageService.new(language_service) }
  let(:redis_client)     { service.client }

  shared_context 'with stored embeddings' do
    let(:text_dict) do
      [
        { 'text_id' => 'text1', 'content' => 'This is text 1', 'text_vector' => [0.1, 0.2, 0.3] },
        { 'text_id' => 'text2', 'content' => 'This is text 2', 'text_vector' => [0.4, 0.5, 0.6] }
      ]
    end

    before do
      FileUtils.cp('spec/fixtures/vectors.json', VECTOR_FILE) unless File.exist?(VECTOR_FILE)
    end

    before(:each) do
      redis_client.flushdb
      service.send(:store_embeddings, text_dict)
    end
  end

  describe '#initialize' do
    let(:vector)  { [0.02027349, -0.020506222, -0.0028574243] }
    let(:question_embedding) { JSON.parse(File.read('spec/fixtures/question_embedding.json')) }

    before do
      # Clear the vector file
      File.delete(VECTOR_FILE) if File.exist?(VECTOR_FILE)
    end

    after do
      # Clear the vector file
      File.delete(VECTOR_FILE) if File.exist?(VECTOR_FILE)
    end

    before do
      allow(EmbeddingsAdapter).to receive(:new).and_return(language_service)
      allow(language_service).to receive(:get_embeddings).and_return(vector)
    end

    describe '#vectorize_texts' do 
      context 'when the vector file does not exist' do
        context 'and the text directory is not empty' do
          it 'vectorizes the texts' do 
            # Set expectation for OpenAiService#get_embeddings
            expect(language_service).to receive(:get_embeddings).and_return(vector)

            # Verify that the texts are vectorized and the vector file is created
            expect(service.send(:vector_file_exists?)).to be true
            expect(File.exist?(VECTOR_FILE)).to be true

            # Verify the content of the vector file
            vector_file_content = JSON.parse(File.read(VECTOR_FILE))
            expect(vector_file_content).to be_an(Array)
            expect(vector_file_content.size).to eq(3)

            # Verify the text vectors and content in the vector file
            vector_file_content.each do |item|
              expect(item['text_id']).to be_truthy
              expect(item['text_vector']).to eq(vector)
              expect(item['content']).to be_truthy
            end
          end
        end
      end
    end

    describe 'load_db #create_index' do 
      context 'when the index does not exist' do
        before do
          # Delete the index and verify
          redis_client.call('FT.DROPINDEX', 'text_idx')
          expect { redis_client.call('FT.INFO', 'text_idx') }.to raise_error(Redis::CommandError)
          
          # Create the index
          service.send(:create_index)
        end

        it 'loads Redis with JSON documents and creates an index' do
          # Verify that Redis is loaded with JSON documents and an index is created
          expect(redis_client.keys).to include("doc:about_us", "doc:terms_of_condition", "doc:faqs")
          expect(redis_client.call('FT.INFO', 'text_idx')).to be_truthy
        end
      end

      context 'when the index exists' do
        it 'skips the creation of index' do
          expect { redis_client.call('FT.INFO', 'text_idx') }.not_to raise_error
          expect { service.send(:create_index) }.to output("Index already exists!\n").to_stdout
        end

        it 'loads Redis with JSON documents and retrieves the index' do
          expect(redis_client.keys).to include("doc:about_us", "doc:terms_of_condition", "doc:faqs")
          expect(redis_client.call('FT.INFO', 'text_idx')).to be_truthy
        end
      end
    end
  end

  describe '#store_embeddings' do
    include_context 'with stored embeddings'
      
    it 'stores embeddings in Redis' do
      expect(redis_client.call('JSON.GET', 'doc:text1')).to be_truthy
      expect(redis_client.call('JSON.GET', 'doc:text2')).to be_truthy

      stored_text2 = JSON.parse(redis_client.call('JSON.GET', 'doc:text2'))

      expect(stored_text2['text_id']).to eq('text2')
      expect(stored_text2['content']).to eq('This is text 2')
      expect(stored_text2['text_vector']).to eq([0.4, 0.5, 0.6])
    end
  end

  describe '#retrieve_embeddings' do
    include_context 'with stored embeddings'
  
    it 'retrieves a specific embedding by text_id' do
      embedding = service.retrieve_embeddings('text1')
  
      expect(embedding.size).to eq(1)
      expect(embedding.first).to eq(
        'text_id' => 'text1',
        'content' => 'This is text 1',
        'text_vector' => [0.1, 0.2, 0.3]
      )
    end
  
    it 'retrieves all embeddings' do
      embeddings = service.retrieve_embeddings

      expected_embeddings = [
        a_hash_including(
          'text_id' => 'text1',
          'content' => 'This is text 1',
          'text_vector' => [0.1, 0.2, 0.3]
        ),
        a_hash_including(
          'text_id' => 'text2',
          'content' => 'This is text 2',
          'text_vector' => [0.4, 0.5, 0.6]
        )
      ]
  
      expect(embeddings).to match_array(expected_embeddings)
    end
  end

  describe '#find_text_by_text_id' do
    include_context 'with stored embeddings'

    it 'finds text by text_id' do
      text_id = 'text1'
      expected_content = 'This is text 1'
      
      content = service.find_text_by_text_id(text_id)
      
      expect(content).to eq(expected_content)
    end
  end
end