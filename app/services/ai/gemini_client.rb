# frozen_string_literal: true

module Ai
  # Base HTTP client for Google Gemini 1.5 Flash API.
  # All AI services in app/services/ai/ call Gemini through this class.
  #
  # Required env var: GEMINI_API_KEY
  # Falls back to deterministic rule-based simulation when the key is absent
  # (so the app works even without an API key in demo/test environments).
  class GeminiClient
    ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    TIMEOUT   = 15 # seconds

    class GeminiError < StandardError; end

    # Sends a single user prompt to Gemini and returns the text response.
    # Returns nil on any network/API error (callers must handle gracefully).
    def self.generate(prompt, temperature: 0.2)
      api_key = ENV["GEMINI_API_KEY"]
      return nil if api_key.blank?

      uri  = URI("#{ENDPOINT}?key=#{api_key}")
      body = {
        contents: [ { role: "user", parts: [ { text: prompt } ] } ],
        generationConfig: {
          temperature: temperature,
          maxOutputTokens: 1024,
          responseMimeType: "application/json"
        }
      }

      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true
      http.read_timeout = TIMEOUT
      http.open_timeout = TIMEOUT

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = body.to_json

      response = http.request(request)
      raise GeminiError, "HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      parsed   = JSON.parse(response.body)
      raw_text = parsed.dig("candidates", 0, "content", "parts", 0, "text")
      raise GeminiError, "Empty Gemini response" if raw_text.blank?

      JSON.parse(raw_text)
    rescue GeminiError, Net::ReadTimeout, Net::OpenTimeout, JSON::ParserError, Errno::ECONNREFUSED => e
      Rails.logger.error("[GeminiClient] #{e.class}: #{e.message}")
      nil
    end
  end
end
