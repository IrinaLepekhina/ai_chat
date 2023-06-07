# spec/services/conversation_ai_handler_spec.rb

require 'rails_helper'

RSpec.describe ConversationAiHandler do
  let(:openai_service) { instance_double("OpenAiService") }
  let(:cosine_similarity_service) { instance_double("CosineSimilarityService") }
  let(:csv_storage_service) { instance_double("CsvStorageService") }
  let(:conversation_ai_handler) { ConversationAiHandler.new(openai_service, cosine_similarity_service, csv_storage_service) }

  describe "#generate_ai_response" do
    let(:content) { "What is the price of water bottles?" }
    let(:question_embedding) { [0.5, 0.6, 0.7] }
    let(:original_text) { "Example Text 1" }
    let(:prompt) do
      <<~PROMPT
        You are an AI assistant. You work for Planta_Tony which is a water store located in Guadalajara.
        You will be asked questions from a customer and will answer in a helpful and friendly manner.
    
        You will be provided company information from Planta_Tony under the [Article] section. The customer question
        will be provided under the [Content] section. You will answer the customer's questions based on the article.
        If the user's question is not answered by the article, you will respond with "I'm sorry, I don't know."
    
        [Article]
        #{original_text}
    
        [Content]
        #{content}
      PROMPT
    end
    let(:ai_response) { "AI response" }

    it "returns the AI response based on the provided content" do
      expect(openai_service).to receive(:get_embeddings).with(content).and_return(question_embedding)
      expect(csv_storage_service).to receive(:retrieve_embeddings).and_return([question_embedding])
      expect(csv_storage_service).to receive(:find_text_at_index).and_return(original_text)
      expect(cosine_similarity_service).to receive(:calculate_similarity).with(question_embedding, question_embedding).and_return(1.0)
      expect(openai_service).to receive(:generate_response).with(prompt).and_return(ai_response)

      response = conversation_ai_handler.generate_ai_response(content)

      expect(response).to eq(ai_response)
    end
  end

  describe "#find_most_similar_text" do
    let(:question_embedding) { [0.5, 0.6, 0.7] }
    let(:embeddings) { [[0.3, 0.4, 0.5], [0.6, 0.7, 0.8], [0.2, 0.9, 0.1]] }
    let(:similarity_array) { [0.8, 0.9, 0.6] }
    let(:max_similarity_index) { 1 }
    let(:original_text) { "Example Text 2" }

    it "returns the most similar text based on question embedding" do
      expect(csv_storage_service).to receive(:retrieve_embeddings).and_return(embeddings)
      expect(cosine_similarity_service).to receive(:calculate_similarity).with(question_embedding, embeddings[0]).and_return(similarity_array[0])
      expect(cosine_similarity_service).to receive(:calculate_similarity).with(question_embedding, embeddings[1]).and_return(similarity_array[1])
      expect(cosine_similarity_service).to receive(:calculate_similarity).with(question_embedding, embeddings[2]).and_return(similarity_array[2])
      expect(conversation_ai_handler).to receive(:find_index_of_max_similarity).with(similarity_array).and_return(max_similarity_index)
      expect(csv_storage_service).to receive(:find_text_at_index).with(max_similarity_index).and_return(original_text)

      result = conversation_ai_handler.send(:find_most_similar_text, question_embedding)

      expect(result).to eq(original_text)
    end
  end
end 