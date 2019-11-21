module Turnout
  module HealthCheckPage
    class Base
      attr_reader :reason

      def initialize(reason = nil, options = {})
        @options = options.is_a?(Hash) ? options : {}
        @reason = reason
      end

      def rack_response(code = nil, retry_after = nil)
        code ||= Turnout.config.response_code_for_health_check
        [code, headers(retry_after), body]
      end

      # Override with an array of media type strings. i.e. text/html
      def self.media_types
        raise NotImplementedError, '.media_types must be overridden in subclasses'
      end
      def media_types() self.class.media_types end

      # Override with a file extension value like 'html' or 'json'
      def self.extension
        raise NotImplementedError, '.extension must be overridden in subclasses'
      end
      def extension() self.class.extension end

      def custom_path
        Pathname.new(Turnout.config.health_check_pages_path).join(filename)
      end

      protected

      def self.inherited(subclass)
        HealthCheckPage.all << subclass
      end

      def headers(retry_after = nil)
        headers = {'Content-Type' => media_types.first, 'Content-Length' => length}
        # Include the Retry-After header unless it wasn't specified
        headers['Retry-After'] = retry_after.to_s unless retry_after.nil?
        headers
      end

      def length
        content.bytesize.to_s
      end

      def body
        [content]
      end

      def content
         file_content.gsub(/{{\s?reason\s?}}/, reason)
      end

      def file_content
        begin
          File.read(path)
        rescue StandardError
          ""
        end
      end

      def path
        if File.exist? custom_path
          custom_path
        else
          default_path
        end
      end

      def default_path
        File.expand_path("../../../../public/#{filename}", __FILE__)
      end


      def filename
        "health_check_page.#{extension}"
      end
    end
  end
end
