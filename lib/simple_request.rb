# frozen_string_literal: true

# Usage: SimpleRequest.posts

class SimpleRequest
  attr_reader :body, :header, :url

  def initialize(**options)
    options.symbolize_keys!
    options.keys.each { |key| instance_variable_set("@#{key}", options[key]) }
  end

  def self.posts(*args)
    new(*args).get
  end

  def posts
    uri = URI('https://jsonplaceholder.typicode.com/posts')

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri, 'Content-Type' => 'application/json')

    request = https.request(request)
    JSON.parse(res.body)
  end
end
