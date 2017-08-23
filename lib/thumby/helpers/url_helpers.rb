def detect_bad_url_params(url)
  if url.nil?
    $logger.warn 'params[:url] was nil, threw a 400'
    throw_default_image 400, 'Bad Request - url pramater required.'
  elsif url !~ /^(https?((:\/\/)|(%3A%2F%2F)))[a-zA-Z0-9].*/       # If url scheme is http:/
    $logger.warn "Bad URL Scheme: #{url}, threw a 400"
    throw_default_image 400, 'Bad Request - Bad url parameter, https?://.* not found'
  end
end

def is_thumby_url?(uri_str)
  uri = URI.parse(uri_str)
  if @thumby_hostnames.include?(uri.host)
    $logger.info "detected a Thumby url => #{uri.to_s}"
    return true
  else
    return false
  end
end

def get_final_source_url(uri_str)
  clean_url = sanitize_url(uri_str)
  uri = URI.parse(clean_url)
  if uri.request_uri =~ /\/t\/e\/.*/ then
    $logger.info 'Ooooo this looks encrypted/encoded!'
    params = {}
    if uri.query != nil then
      uri.query.split('&').each do |param|
        key_value = param.split('=')
        params[key_value[0]] = key_value[1]
      end
    end
    encoded_string = uri.path.gsub(/\/t\/e\//, '')
    salt = (params['salt'] == nil) ? @encryption_iv : params['salt']
    decoded_string = decode_string encoded_string
    decrypted_uri = decrypt_string(salt, decoded_string)
    if decrypted_uri =~ /\/t\/[a-zA-Z0-9].*\/[a-zA-Z0-9].*\/\?url=/
      clean_url = sanitize_url(decrypted_uri.split('url=')[-1])
    else
      clean_url = sanitize_url(decrypted_uri)
    end
    uri = URI.parse(clean_url)
  end
  final_url = uri.to_s.split('url=')[-1]
  final_url = URI.decode(final_url) if final_url =~ /^https?%3A%2F%2F.*/
  $logger.info "Guessing #{final_url} is the final url to fetch from"
  return final_url
end


def sanitize_url(url)
  detect_bad_url_params(url)
  url_str = url =~ /^(https?%3A).*/ ? URI.decode(url) : url
  begin
    encoded_uri = URI.parse(url_str).normalize.to_s
  rescue URI::InvalidURIError
    encoded_uri = Addressable::URI.parse(url_str).normalize.to_s
    URI.parse(encoded_uri)
  rescue Addressable::URI::InvalidURIError => e
    raise BadURI, e.message
  rescue URI::InvalidURIError => e
    raise BadURI, e.message
  end
  #encoded_url = Addressable::URI.parse(url_str).normalize.to_s
  return encoded_uri
end