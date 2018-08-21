# frozen_string_literal: true

module ResponseHelpers
  # Parse JSON response to ruby hash
  def json_parse_response_body
    JSON.parse(response.body, symbolize_names: true)
  end

  def json_parse(string)
    JSON.parse(string, symbolize_names: true)
  end
end
