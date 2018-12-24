require './lib/client.rb'

RSpec.describe Client do
  subject { described_class.new('./spec/fixtures/hot_dog.jpg') }
  # mock an authorizer that we can call fetch_access_token! on
  let(:authorizer) { double }

  describe '#headers' do
    let(:headers) do
      {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer google_authentication_token'
      }
    end

    before do
      # stub #make_creds method and have it return our stub authorizer
      allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds) { authorizer }
      # stub #fetch_access_token! and have it return a hash with the correct key and
      # a fake value
      allow(authorizer).to receive(:fetch_access_token!) {
        { 'access_token' => 'google_authentication_token' }
      }
    end

    it 'returns the request headers' do
      expect(subject.headers).to eq headers
    end
  end

  describe '#body' do
    let(:body) do
      {
        payload: {
          image: {
            imageBytes: 'base64_encoded_image'
          }
        }
      }.to_json
    end

    before do
      allow(Base64).to receive(:strict_encode64) { 'base64_encoded_image' }
    end

    it 'returns the request body' do
      expect(subject.body).to eq body
    end
  end

  describe '#post' do
    let(:response) { double }
    let(:json) { "Hello World".to_json }

    before { allow(response).to receive(:body) { json } }

    it 'sends a post request' do
      expect(HTTPClient).to receive(:post).with(
        described_class::URL,
        body: subject.body,
        header: subject.headers
      ) { response }

      subject.post
    end
  end
end
