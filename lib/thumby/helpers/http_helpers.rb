def strip_redirects(uri_str, limit = 3)
  # You should choose a better exception.
  if limit == 0
    $logger.error "#{params[:url]} lead to redirect loop"
    throw_default_image 504, 'Detected redirect loop'
  end

  uri_str = sanitize_url(uri_str)
  uri_parsed = URI.parse(uri_str)
  response = http_request_head(uri_str)

  if response.code =~ /301|302/
    $logger.info "Recieved #{response.code} from #{uri_str}, being sent to #{response['location']}"
    location_parsed = URI.parse(response['location'])
    location_uri = location_parsed.query.nil? ? location_parsed.path : "#{location_parsed.path}?#{location_parsed.query}"
    redirect_location = location_parsed.host.nil? ? "#{uri_parsed.scheme}://#{uri_parsed.host}#{location_uri}" : response['location']
    strip_redirects(redirect_location, limit - 1)
  elsif response['content-type'] == 'text/html' and response.code == '200' then
    $logger.error "#{params[:url]} is html and not jpeg or png"
    throw_default_image 500, 'Detected url is an html and not a jpeg or png extension'
  else
    uri_str
  end
end # END strip_redirects


def http_request_head(uri_str)
  uri = URI.parse(uri_str)
  begin
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    request = Net::HTTP::Head.new(uri.request_uri)
    resp = http.request(request)
    return resp
  rescue Timeout::Error => e
    $logger.error "#{e.message}: to => #{params[:url]}"
    throw_default_image 504, "Gateway Timeout - #{url}"
  rescue SocketError => se
    $logger.error "#{params[:url]} Socket Error!!!!  Exception: #{se.message}"
    throw_default_image 502, "Socket Error: #{se.message}, Origin: #{url}"
  rescue Errno::ECONNREFUSED => cr
    $logger.error "#{params[:url]} Connection Refused!!!!  Exception: #{cr.message}"
    throw_default_image 502, "Connection Refused!!!!  Exception: #{cr.message}"
  end
end
