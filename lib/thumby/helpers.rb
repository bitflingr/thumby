class Thumby
  class SinatraApp < ::Sinatra::Base # :nodoc:
    helpers do
      require 'thumby/helpers/url_helpers'
      require 'thumby/helpers/http_helpers'
      require 'thumby/helpers/decode_helpers'

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

        if img.size == 0
          $logger.error "#{params[:url]} is 0 bytes, cannot resize what is not there..."
          cache_control :no_cache
          throw :halt, [500, 'image is 0 bytes!']
        else
          img.strip!
          img.encode!(img.format)
          img = cleanup_gif(img) if img.ext == 'gif'
          $logger.info "Image #{params[:url]}, WIDTH: #{img.width}, HEIGHT: #{img.height}"

          # First check to see the requested size is too big.
          if requested_height > @max_size || requested_width > @max_size
            $logger.info "Requested size #{requested_width}x#{requested_height} exceeded max allowed: #{@max_size} for #{params[:url]}.  Leaving image size alone."

          # BLUR_MODE ENABLED
          elsif @blur_mode == 'enabled'
            $logger.info 'Blur Mode enabled.'
            img = blur_padding(img, requested_width, requested_height)

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
