require 'rails_helper'

describe VectorSimilarityService, type: :service do
  let(:question_embedding) { JSON.parse(File.read('spec/fixtures/question_embedding.json')) }
  let(:query_vector)       { JSON.parse(File.read('spec/fixtures/chat_entry.json')) }
  
  let(:mock_language_service) { instance_double('EmbeddingsAdapter') }
  
  let(:redis_service) do
    RedisStorageService.new(
      language_service: mock_language_service,
      redis_client: mock_redis_client
    )
  end

  let(:mock_redis_client) do
    instance_double('Redis').tap do |client|
      allow(client).to receive(:keys).with("doc:*").and_return(['doc:sample1', 'doc:sample2']) # Simulate loaded Redis with vectorized texts
      allow(client).to receive(:pipelined).and_yield(client)
      allow(client).to receive(:call).with(any_args).and_return(
        [
          ["distance",   "0.1", "$", "{\"text_id\":\"text1\",\"content\":\"Text 1 content\"}"],
          ["distance",   "0.2", "$", "{\"text_id\":\"text2\",\"content\":\"Text 2 content\"}"],
          ["other_type", "0.3", "$", "{\"text_id\":\"text3\",\"content\":\"Text 3 content\"}"]
        ]
      )
    end
  end

  before do
    allow(mock_redis_client).to receive(:pipelined).and_yield(mock_redis_client)
  end

  describe 'VectorSimilarityService with Redis backend' do
    let(:vss) { VectorSimilarityService.new(redis_service) }

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
            ["distance",   "0.1", "$", "{\"text_id\":\"text1\",\"content\":\"Text 1 content\"}"],
            ["distance",   "0.2", "$", "{\"text_id\":\"text2\",\"content\":\"Text 2 content\"}"],
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