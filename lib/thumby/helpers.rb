class Thumby
  class SinatraApp < ::Sinatra::Base # :nodoc:
    helpers do
      require 'thumby/helpers/url_helpers'
      require 'thumby/helpers/http_helpers'
      require 'thumby/helpers/encrypt_encode_helpers'

      def cleanup_gif(img)
        if @gif_mode == 'single'
          $logger.info 'Coalescing GIF, converting to .jpg and selecting first frame'
          img = img.convert('-coalesce', :format => 'jpg', 'frame' => 0)
          img = img.encode('jpg')
        else
          $logger.info 'Coalescing GIF'
          img = img.convert('-coalesce')
        end
        img
      end

      def resize_image(img, requested_width, requested_height)
        $logger.info "Stripping image #{params[:url]}, TEMPFILE:#{img.tempfile.path}"
        img.strip!

        if img.ext == 'html'
          $logger.error "#{params[:url]} is html and not jpeg or png"
          cache_control :no_cache
          throw :halt, [500, 'Detected url is an html and not a jpeg or png extension']
        elsif img.size == 0
          $logger.error "#{params[:url]} is 0 bytes, cannot resize what is not there..."
          cache_control :no_cache
          throw :halt, [500, 'image is 0 bytes!']
        else
          img.encode!(img.format)
          img = cleanup_gif(img) if img.ext == 'gif'
          $logger.info "Image #{params[:url]}, WIDTH: #{img.width}, HEIGHT: #{img.height}"

          # First check to see the requested size is too big.
          if requested_height > @max_size || requested_width > @max_size
            $logger.info "Requested size #{requested_width}x#{requested_height} exceeded max allowed: #{@max_size} for #{params[:url]}.  Leaving image size alone."

          # BLUR_MODE ENABLED
          elsif @blur_mode == 'enabled'
            # If image height is 1.5 times larger than requested height and the thumby config for blur_mode is 'enabled'.
            # This is so if the config has blur_mode 'enabled' and the request came through '/t/' we blur images that are 1.5 times larger than requested height to have portrait images fit in landscapes.
            if img.height > ((requested_height * 1.5)) && @blur_mode == 'enabled'
              $logger.info 'Blur Mode enabled.'
              $logger.info "Requested image height(#{img.height}) is greater than requested height(#{requested_height}) * 1.5"
              img = blur_padding(img, requested_width, requested_height)

            # This blur_mode is typically overridden when uri request is /b/*
            else @blur_mode == 'enabled'
                 $logger.info 'Blur Mode enabled.'
                 img = blur_padding(img, requested_width, requested_height)
            end

          # BLUR_DISABLED
          else
            if img.width < requested_width
              $logger.info "Image width is smaller than requested width.  Requested size was #{params[:dimensions]}.  Leaving image size alone"
            elsif img.height < requested_height
              $logger.info "Image height is smaller than requested height.  Requested size was #{params[:dimensions]}.  Resizing image #{params[:url]} to #{requested_width}x#{img.height}, TEMPFILE:#{img.tempfile.path}"
              img.thumb!("#{requested_width}x#{img.height}##{$gravity_map[params[:gravity]]}") # if img.ext != 'gif'
            else
              $logger.info "Resizing image #{params[:url]} to #{params[:dimensions]}, TEMPFILE:#{img.tempfile.path}"
              img = img.thumb("#{requested_width}x#{requested_height}##{$gravity_map[params[:gravity]]}") # if img.ext != 'gif'
            end
          end

          # $logger.info "Encoding image #{params[:url]}, TEMPFILE:#{img.tempfile.path}" and img.encode!(:jpg) if img.ext != 'gif'
          img.encode!(img.format)
          $logger.info "responding with image #{params[:url]}"
          return img
        end
      end

      def blur_padding(img, requested_width, requested_height)
        $logger.info "Image #{params[:url]}, WIDTH: #{img.width}, HEIGHT: #{img.height}"
        $logger.info "Cropping image by height only, HEIGHT: #{requested_height}, TEMPFILE:#{img.tempfile.path}"
        foreground_image = img.thumb("x#{requested_height}")
        $logger.info "BLOWING UP Background image -resize %200x%200^^, TEMPFILE:#{img.tempfile.path}"
        img = img.convert('-resize %200x%200^^')
        $logger.info "CROPPING Background image - #{requested_width}x#{requested_height}##{$gravity_map[params[:gravity]]}, TEMPFILE:#{img.tempfile.path}"
        img = img.thumb("#{requested_width}x#{requested_height}##{$gravity_map[params[:gravity]]}")
        $logger.info "BLURRING Background image, TEMPFILE:#{img.tempfile.path}"
        img = img.blur
        $logger.info "Combining images - x#{requested_height}, TEMPFILE:#{img.file.path}"
        layered_img = img.layer_thumb(bg_path: foreground_image.file.path)
        $logger.info "returning layered image #{params[:url]}"
        layered_img
      end

      def orientation?(width, height)
        if width > height
          'landscape'
        elsif width < height
          'portrait'
        elsif width == height
          'square'
        end
      end

      def throw_default_image(code, message)
        status_code = code.to_i
        cache_control :no_cache
        content_type :'image/jpeg'
        response.headers['X-Message'] = message
        img = @image.fetch_file($fallbackimage)
        new_image = resize_image(img, 300, 300)
        throw :halt, [status_code, new_image.data]
      end
    end
  end
end
