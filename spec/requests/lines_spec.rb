require 'swagger_helper'
RSpec.describe 'api/v1/encounters_controller', type: :request do
  path '/api/lines/{lineId}' do
    get 'Get line content from file' do
      tags 'Lines'
      consumes 'application/json'
      parameter name: :lineId, in: :path, description: 'Line number', required: true, type: 'integer', format: 'int64'
      response '200', 'Found Line' do
        let(:lineId) { 1 }
        run_test!
      end

      response '400', 'Must be an integer' do
        let(:lineId) { 'ola' }
        run_test!
      end

      response '413', 'Number line is to big' do
        let(:lineId) { 1_000_000_000_000_000_000 }
        run_test!
      end
    end
  end
end
