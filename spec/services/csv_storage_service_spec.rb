# spec/services/csv_storage_service_spec.rb

require 'rails_helper'
# before do
#   allow(csv_storage_service).to receive(:read_embeddings_from_csv).and_return(embeddings)
# end

describe CsvStorageService, type: :service do
  let(:csv_path) { "#{Rails.root}/spec/fixtures/embeddings.csv"}
  let(:csv_storage_service) { CsvStorageService.new(csv_path) }

  describe '#retrieve_embeddings' do
    context 'when text is provided' do
      let(:text) { 'Example Text 1' }
      let(:embeddings) { [{ 'embedding' => [0.1, 0.2, 0.3], 'text' => text }] }

      it 'returns the embeddings for the specified text' do
        expect(csv_storage_service.retrieve_embeddings(text)).to eq(embeddings)
      end 
    end 

    context 'when text is not provided' do
      let(:embeddings) { [
        { 'embedding' => [0.1, 0.2, 0.3], 'text' => 'Example Text 1' },
        { 'embedding' => [0.4, 0.5, 0.6], 'text' => 'Example Text 2' },
        { 'embedding' => [0.7, 0.8, 0.9], 'text' => 'Example Text 3' }
      ] }

      it 'returns all embeddings' do
        expect(csv_storage_service.retrieve_embeddings).to eq(embeddings)
      end
    end
  end

  describe '#find_text_at_text_id' do
    it 'returns the text at the specified text_id' do
      expect(csv_storage_service.find_text_at_text_id(1)).to eq('Example Text 2')
    end
  end
end