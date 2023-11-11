module Api
  module V1
    class PromptsController < ApiController

      def index
        @prompts = Prompt.page(params[:page]).per(10)

        respond_to do |format|
          format.html
          format.json { json_response(@prompts, :ok) }
        end
      end

      def show
        @prompt = Prompt.find(params[:id])
        respond_to do |format|
          format.html
          format.json { json_response(@prompt, :found) }
        end
      end

      def new
        @prompt = Prompt.new
      end

      def create
        @prompt = Prompt.new(prompt_params)

        return unless @prompt.save!
        respond_to do |format|
          format.html { redirect_to api_prompt_url(@prompt), notice: "Prompt created successfully" }
        end
      end

      private

      def prompt_params
        params.require(:prompt).permit(
          :content
        )
      end
    end
  end
end
