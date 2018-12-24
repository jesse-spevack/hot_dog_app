require 'googleauth'
require 'httpclient'
require './config.rb'

class Client
  SCOPE = 'https://www.googleapis.com/auth/cloud-platform'.freeze
  AUTH_FILE_PATH = './secret_authorization.json'.freeze
  URL = Config::URL

  attr_reader :image_path

  def initialize(image_path)
    @image_path = image_path
  end

  def headers
    {
      'Content-Type': 'application/json',
      'Authorization': "Bearer #{google_authentication_token}"
    }
  end

  def google_authentication_token
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(AUTH_FILE_PATH),
      scope: SCOPE
    )

    authorizer.fetch_access_token!['access_token']
  end

  def body
    {
      payload: {
        image: {
          imageBytes: Base64.strict_encode64(open(image_path).read)
        }
      }
    }.to_json
  end

  def post
    response = HTTPClient.post(URL, body: body, header: headers)
    MultiJson.load(response.body)
  end
end
