# frozen_string_literal: true

module ResponseHelpers
  # Parse JSON response to ruby hash
  def json_parse
    JSON.parse(response.body, symbolize_names: true)
  end
end
