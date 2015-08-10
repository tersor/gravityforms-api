require 'faraday'
require 'base64'
require 'cgi'
require 'openssl'

module Gravityforms
  module Api
    class Request
      attr_reader :url
      def initialize(route, method)
        expires = (Time.now+60*60).to_time.to_i
        api_key = Gravityforms::Api.configuration.api_key
        api_url = Gravityforms::Api.configuration.api_url
        signature = calculate_signature(route, method, expires, api_key)
        @url = "#{api_url}#{route}/?api_key=#{api_key}&signature=#{signature}&expires=#{expires}"
      end

      def get
        response = Faraday.get(self.url)
      end

      def post(payload)
        response = Faraday.post(self.url, payload)
      end

      def calculate_signature(route, method, expires, api_key)
        private_key = Gravityforms::Api.configuration.private_key
        string_to_sign = sprintf("%s:%s:%s:%s", api_key, method, route, expires)
        hmac = OpenSSL::HMAC.digest('sha1',private_key,string_to_sign).strip
        signature = CGI.escape(Base64.encode64("#{hmac}\n")).gsub("K%0A", "%3D")
      end
    end
  end
end