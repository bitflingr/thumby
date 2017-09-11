def decode_string(base64_string)
  begin
    decoded_string = Base64.urlsafe_decode64(base64_string)
  rescue ArgumentError
    $logger.error "#{base64_string} Invalid Base64!!!!"
    cache_control :no_cache
    content_type :'image/jpeg'
    response.headers['X-Message'] = 'Invalid Base64 - ' + base64_string
    img = @image.fetch_file($fallbackimage)
    new_image = resize_image(img, 300, 300)
    throw :halt, [400, new_image.data]
  end
  decoded_string
end