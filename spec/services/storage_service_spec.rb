# spec/services/storage_service_spec.rb

require 'rails_helper'

describe StorageService, type: :service do
  let(:storage_service) { TestStorageService.new }

  class TestStorageService < StorageService
  end

  describe '#store_embeddings' do
    it 'raises NotImplementedError when called directly on the abstract class' do
      expect { storage_service.store_embeddings({}) }.to raise_error(NotImplementedError)
    end
  end

  describe '#retrieve_embeddings' do
    it 'raises NotImplementedError when called directly on the abstract class' do
      expect { storage_service.retrieve_embeddings }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError when called directly on the abstract class with text_id argument' do
      expect { storage_service.retrieve_embeddings('text_id') }.to raise_error(NotImplementedError)
    end
  end

  describe '#find_text_by_text_id' do
    it 'raises NotImplementedError when called directly on the abstract class' do
      expect { storage_service.find_text_by_text_id('text_id') }.to raise_error(NotImplementedError)
    end
  end
end
