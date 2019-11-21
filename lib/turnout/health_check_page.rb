require 'pathname'
module Turnout
  module HealthCheckPage
    require 'rack/accept'

    def self.all
      @all ||= []
    end

    def self.best_for(env)
      request = Rack::Accept::Request.new(env)

      all_types = all.map(&:media_types).flatten
      best_type = request.best_media_type(all_types)
      best = all.find { |page| page.media_types.include?(best_type) && File.exist?(page.new.custom_path) }
      best || Turnout.config.default_health_check_page
    end

    require 'turnout/health_check_page/base'
    require 'turnout/health_check_page/erb'
    require 'turnout/health_check_page/html'
    require 'turnout/health_check_page/json'
  end
end
