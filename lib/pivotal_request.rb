class PivotalRequest

  def self.request uri, method, token, params = {}
    uri = URI.parse uri
    request = eval("Net::HTTP::#{method.humanize}").new uri

    request['X-Trackertoken'] = token

    if params.present?
      request.content_type = 'application/json'
      request.body = JSON.dump params
    end

    req_options = {
      use_ssl: uri.scheme == 'https',
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request request
    end

    response.body
  end

end
