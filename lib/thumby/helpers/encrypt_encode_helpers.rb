def decrypt_string(key=nil, decoded_string)
  salt = (key == nil) ? @encryption_iv : key
  decrypted_string = aes128_decrypt(@aes_key, salt, decoded_string)
  $logger.info "decrypted string is #{decrypted_string}"
  return decrypted_string
end

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

def aes128_decrypt(key, iv, data)
  aes = OpenSSL::Cipher.new('AES-128-CBC')
  aes.iv = iv
  aes.key = key
  aes.decrypt
  begin
    aes.update(data) + aes.final
  rescue ArgumentError
    $logger.error 'Invalid AES-128 data!!!!'
    cache_control :no_cache
    throw :halt, [400, 'Invalid AES-128 data!!!!'] #status 500
  end
end