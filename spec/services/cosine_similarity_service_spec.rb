# spec/services/cosine_similarity_service_spec.rb

require 'rails_helper'

RSpec.describe CosineSimilarityService do
  describe '#calculate_similarity' do
    let(:question_embedding) { [0.1, 0.2, 0.3] } 
    let(:text_embedding) { [0.4, 0.5, 0.6] }
    let(:similarity) { 0.97 }
    subject { described_class.new }

    it 'calls the cosine_similarity method and returns the similarity' do
      expect(subject).to receive(:cosine_similarity).with(question_embedding, text_embedding).and_return(similarity)
      expect(subject.calculate_similarity(question_embedding, text_embedding).round(2)).to eq(similarity)
    end 
  end
end