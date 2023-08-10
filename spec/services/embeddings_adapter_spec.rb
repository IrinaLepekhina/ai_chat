# spec/services/embeddings_adapter_spec.rb

require 'rails_helper'

describe EmbeddingsAdapter, type: :service do
  let(:language_service) { instance_double('LanguageService') }
  let(:embeddings_adapter) { EmbeddingsAdapter.new(language_service) }

  describe '#get_embeddings' do
    it 'delegates to the language service to get embeddings' do
      content = 'This is a sample text.'

      expect(language_service).to receive(:get_embeddings).with(content).and_return('embeddings_data')
      result = embeddings_adapter.get_embeddings(content)

      expect(result).to eq('embeddings_data')
    end
  end

  describe '#generate_response' do
    it 'delegates to the language service to generate a response' do
      prompt = 'Tell me a joke.'

      expect(language_service).to receive(:generate_response).with(prompt).and_return('generated_response')
      result = embeddings_adapter.generate_response(prompt)

      expect(result).to eq('generated_response')
    end
  end
end
