class Thumby
  class SinatraApp < ::Sinatra::Base
    def initialize(thumby_hostnames, preview_server, options = {})
      @preview_server = preview_server
      @convert_command = options[:convert_command] || 'convert'
      @identify_command = options[:identify_command] || 'identify'
      @cache_duration = options[:cache_duration] || 3600*24
      @aes_key = options[:encryption_key] || 'CHANGE_ME'
      @encryption_iv = options[:encryption_iv] || 'CHANGE_ME'
      @gif_mode = options[:gif_mode] || 'single'
      @blur_mode = options[:blur_mode] || 'disabled'
      @max_size = options[:max_size] || 2000
      @thumby_hostnames = thumby_hostnames || ['localhost']
      @aws_access_key_id = options[:aws_access_key_id]
      @aws_secret_access_key = options[:aws_secret_access_key]
      super()
    end

    register Sinatra::StaticAssets
    register Sinatra::SimpleNavigation
    SimpleNavigation::config_file_paths << File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'config')


    configure :production do
      logdir = File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'log')
      Dir.mkdir(logdir) unless File.exist?(logdir)
      $logger = Logger.new(logdir + '/thumby.log', 7, 'daily')
      $logger.level = Logger::INFO
    end

    configure :development do
      $logger = Logger.new(STDOUT)
    end

    configure :test do
      $logger = Logger.new(NIL)
    end

    configure do
      set :views, File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'views')
      set :static, true
      set :public_folder, File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'public')
      set :static, true

      $gravity_map = {
          'NorthWest' => 'nw',
          'North' => 'n',
          'NorthEast' => 'ne',
          'West' => 'w',
          'Center' => 'c',
          'East' => 'e',
          'SouthWest' => 'sw',
          'South' => 's',
          'SouthEast' => 'se'
      }

      $fallbackimage = File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'public') + '/g-placeholder.png'
    end


    before do
      logdir = File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'log')
      Dir.mkdir(logdir) unless File.exist?(logdir)
      max_age = @cache_duration

      @image = Dragonfly.app.configure_with(:imagemagick)
      @image.configure do
        plugin :imagemagick,
          convert_command: @convert_command, # defaults to "convert"
          identify_command: @identify_command  # defaults to "identify"
          response_header 'Cache-Control', "public, max-age=#{max_age}"
          response_header 'ETag' do |job,request,headers|
            if job.process_steps[-2].try(:name) == :layer_thumb
              Digest::SHA1.file(job.file.path).hexdigest
            else
              job.signature
            end
          end

          processor :strip do |content|
            content.process! :convert, '-strip'
          end

          processor :blur do |content|
            content.process! :convert, '-blur 0x50'
          end

          processor :layer_thumb do |content, *args|
            args    = args.first || {}
            bg_layer = args[:bg_path] || 'red'
            content.process! :convert, "-gravity north #{bg_layer} -composite"
          end

        end

      Dragonfly.logger = Logger.new(NIL)
      @preview_prefix = @preview_server
    end

    get '/' do
      if params[:url] and params[:size] and params[:gravity] then
        @uri = "#{params[:size]}/#{params[:gravity]}/?url=#{URI.encode(params[:url], '?=&')}"
      end
      erb :home
    end

    get '/pingdom' do
      status 200
      'OK'
    end

    get '/rekognition/' do
      $logger.info 'Rekognition path...'
      #clean_url = @decoded_url ? sanitize_url(@decoded_url) : sanitize_url(params[:url])
      #url = is_thumby_url?(clean_url) ? strip_redirects(get_final_source_url(clean_url)) : strip_redirects(clean_url)

      rekognition_client = Aws::Rekognition::Client.new(
        region: 'us-west-2',
        access_key_id: @aws_access_key_id,
        secret_access_key: @aws_secret_access_key
      )
      #require 'pp'
      results = rekognition_client.detect_faces({
        image: {
          s3_object: {
            bucket: "grv-imagedrop",
            name: "/blacklist/1260/original/Blacklist_CatchUp_Meta_v1_300x300.jpg.jpg",
          },
        },
      })

      #results = rekognition_client.detect_faces(img)
      status 200
      results
      #new_image = params[:dimensions] == 'original' ? img.encode(img.format) : resize_image(img, requested_width, requested_height)

    end

    get '/t/e/:encoded_aes?*' do
      $logger.info 'Recieved an encrypted url.  Attempting to decode and decrypt'
      decoded_string = decode_string params[:encoded_aes]
      decrypted_string = decrypt_string params[:salt], decoded_string
      url = URI.parse(decrypted_string)

      query_param = {}
      url.query.split('?').each{ |q| kv = q.split('='); query_param[:"#{kv[0]}"] = kv[1] }
      @decoded_url = query_param[:url] if query_param.has_key?(:url)
      request.path_info = url.path
      request.env['REQUEST_URI'] = url.path + '?' + url.query
      $logger.info "Passing the decrypted URI to the next matched Sinatra route #{request.env['REQUEST_URI']}"
      pass
    end

    get '/t/:dimensions/:gravity/:base64' do
      $logger.info 'Recieved an encoded url.  Attempting to decode'
      @decoded_url = Base64.urlsafe_decode64(params[:base64])
      $logger.info "decoded string is #{@decoded_url}"
      request.path_info = "/t/#{params[:dimensions]}/#{params[:gravity]}/"
      request.env['REQUEST_URI'] = "/t/#{params[:dimensions]}/#{params[:gravity]}/?url=#{@decoded_url}"
      $logger.info "Passing the decoded URI to the next matched Sinatra route #{request.env['REQUEST_URI']}"
      pass
    end


    get '/:mode/:dimensions/:gravity/?*' do
      clean_url = @decoded_url ? sanitize_url(@decoded_url) : sanitize_url(params[:url])
      url = is_thumby_url?(clean_url) ? strip_redirects(get_final_source_url(clean_url)) : strip_redirects(clean_url)
      requested_width, requested_height = params[:dimensions].split('x')
      requested_width = requested_width.to_i
      requested_height = requested_height.to_i
      @blur_mode = 'enabled' if params[:mode] == 'b'

      $logger.info "Fetching #{url}"
      begin
        img = @image.fetch_url(url)
        new_image = params[:dimensions] == 'original' ? img.encode(img.format) : resize_image(img, requested_width, requested_height)
        if new_image.ext == 'webp'
          content_type :'image/webp'
          new_image.data
        else
          new_image.to_response(env)
        end


      rescue Dragonfly::Job::FetchUrl::ErrorResponse => error_response
        $logger.warn "#{url} returned #{error_response.status}"
        cache_control :no_cache
        status error_response.status
        content_type :'image/jpeg'
        response.headers['X-Message'] = "URL returned #{error_response.status} - #{url}"
        img = @image.fetch_file($fallbackimage)
        new_image = resize_image(img,requested_width, requested_height)
        new_image.data

      rescue Timeout::Error => to
        $logger.error "#{params[:url]} Timed Out!!!!}"
        cache_control :no_cache
        status 504
        content_type :'image/jpeg'
        response.headers['X-Message'] = "Gateway Timeout - #{url}"
        img = @image.fetch_file($fallbackimage)
        new_image = resize_image(img,requested_width, requested_height)
        new_image.data

      rescue SocketError => se
        $logger.error "#{params[:url]} Socket Error!!!!  Exception: #{se.message}"
        cache_control :no_cache
        status 502
        content_type :'image/jpeg'
        response.headers['X-Message'] = "Socket Error: #{se.message}|#{url}"
        img = @image.fetch_file($fallbackimage)
        new_image = resize_image(img,requested_width, requested_height)
        new_image.data

      rescue Exception => e
        $logger.error "ERROR 500: #{url}, Exception: #{e.message} Backtrace: #{e.backtrace}"
        cache_control :no_cache
        status 500
        "#{e.message} ##### #{e.backtrace}"
      end
    end

    get %r{/docs|/docs/} do
      markdown File.read(File.join(File.dirname(__FILE__), '../..', 'README.md')), :layout_engine => :erb
    end

  end # END of class SinatraApp
end # END of class Thumby
