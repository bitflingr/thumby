def decode_string(base64_string)
  begin
    decoded_string = Base64.urlsafe_decode64(base64_string)
  rescue ArgumentError
    $logger.error "#{base64_string} Invalid Base64!!!!"
    cache_control :no_cache
    throw :halt, [400, 'Invalid Base64 - ' + base64_string]
  end
  return decoded_string
end