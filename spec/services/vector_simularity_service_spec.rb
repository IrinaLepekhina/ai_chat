require 'rails_helper'

describe VectorSimularityService, type: :service do
  let(:question_embedding) { JSON.parse(File.read('spec/fixtures/question_embedding.json')) }
  let(:query_vector)       { JSON.parse(File.read('spec/fixtures/chat_entry.json')) }
 
  before(:all) do
    FileUtils.cp('spec/fixtures/vectors.json', VECTOR_FILE) unless File.exist?(VECTOR_FILE)
  end

  describe 'VectorSimularityService with Redis backend' do
    let(:redis_service) { RedisStorageService.new }
    let(:vss)           { VectorSimularityService.new(redis_service) }

    before(:each) do
      redis_service.set_query(query_vector)
    end
  
    after(:each) do
      # Clean up test data from the Redis index
      redis_service.client.call('FT.DROPINDEX', 'text_idx', 'DD')
    end

    describe '#initialize' do
      it 'sets the redis service correctly' do
        expect(vss.instance_variable_get(:@redis_service)).to eq(redis_service)
      end
    end

    describe '#query_original_text' do
      context 'with empty question embedding' do
        it 'returns hash with nil' do
          empty_embedding = []

          original = vss.query_original_text(empty_embedding)
          expect(original[:text]).to be_falsy
        end
      end

      context 'with invalid question embedding' do
        it 'raises an error' do
          invalid_embedding = [nil, 'invalid', 3.14]

          expect { vss.query_original_text(invalid_embedding) }.to raise_error(StandardError)
        end
      end

      context 'with correct question embedding' do
        it 'performs a search query and returns the correct result' do
          original = vss.query_original_text(question_embedding)

          expect(original).to be_an(Hash)
          expect(original[:text]).to be_truthy
        end
      end
    end

    describe '#find_max_similarity' do
      context 'with similarity_array containing valid elements' do
        let(:similarity_array) do
          [
            ["distance", "0.1", "$", "{\"text_id\":\"text1\",\"content\":\"Text 1 content\"}"],
            ["distance", "0.2", "$", "{\"text_id\":\"text2\",\"content\":\"Text 2 content\"}"],
            ["other_type", "0.3", "$", "{\"text_id\":\"text3\",\"content\":\"Text 3 content\"}"]
          ]
        end

        it 'returns the closest text and text_id' do
          result = vss.send(:find_max_similarity, similarity_array)

          expect(result).to be_a(Hash)
          expect(result[:text]).to eq("Text 1 content")
          expect(result[:text_id]).to eq("text1")
        end
      end

      context 'with similarity_array containing no valid elements' do
        let(:similarity_array) do
          [
            ["other_type", "0.3", "$", "{\"text_id\":\"text3\",\"content\":\"Text 3 content\"}"],
            ["other_type", "0.4", "$", "{\"text_id\":\"text4\",\"content\":\"Text 4 content\"}"]
          ]
        end

        it 'returns a hash with nil values' do
          result = vss.send(:find_max_similarity, similarity_array)

          expect(result).to be_a(Hash)
          expect(result[:text]).to be_nil
          expect(result[:text_id]).to be_nil
        end
      end
    end
  end
end