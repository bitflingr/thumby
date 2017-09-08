def strip_redirects(uri_str, limit = 3)
  # You should choose a better exception.
  raise ArgumentError, 'too many HTTP redirects' if limit == 0
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
    cache_control :no_cache
    throw :halt, [500, 'Detected url is an html and not a jpeg or png extension']
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
    cache_control :no_cache
    content_type :'image/jpeg'
    response.headers['X-Message'] = "Gateway Timeout - #{url}"
    img = @image.fetch_file($fallbackimage)
    new_image = resize_image(img, 300, 300)
    throw :halt, [504, new_image.data]

  rescue SocketError => se
    $logger.error "#{params[:url]} Socket Error!!!!  Exception: #{se.message}"
    cache_control :no_cache
    content_type :'image/jpeg'
    response.headers['X-Message'] = "Socket Error: #{se.message}, Origin: #{url}"
    img = @image.fetch_file($fallbackimage)
    new_image = resize_image(img,300, 300)
    throw :halt, [502, new_image.data]

  rescue Errno::ECONNREFUSED => cr
    $logger.error "#{params[:url]} Connection Refused!!!!  Exception: #{cr.message}"
    cache_control :no_cache
    content_type :'image/jpeg'
    response.headers['X-Message'] = "Connection Refused!!!!  Exception: #{cr.message}"
    img = @image.fetch_file($fallbackimage)
    new_image = resize_image(img,300, 300)
    throw :halt, [502, new_image.data]
  end
end
