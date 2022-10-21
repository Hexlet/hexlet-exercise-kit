# frozen_string_literal: true

require 'dotenv/load'

module RepoDownloader
  module Cli
    def self.run
      log_level = ENV['DEBUG'] == 'true' ? :debug : :info
      Log.level(log_level)

      if ENV['GITLAB_API_PRIVATE_TOKEN'].nil? || ENV['GITLAB_API_PRIVATE_TOKEN'].empty?
        raise 'You should to add Gitlab private token in .env file'
      end

      repos_path =
        if ENV['PATH_TO_REPOS'].nil?
          File.expand_path('..', Dir.getwd)
        else
          File.expand_path(ENV['PATH_TO_REPOS'])
        end

      options = {
        parallel: ENV['PARALLEL'].to_i || 8,
        filter: ENV.fetch('FILTER', nil),
        update: ENV.fetch('UPDATE', nil) == 'true',
        gitlab_endpoint: ENV.fetch('GITLAB_API_ENDPOINT', nil),
        gitlab_private_token: ENV.fetch('GITLAB_API_PRIVATE_TOKEN', nil),
        repos_path:
      }

      downloader = RepoDownloader::Downloader.new(options)

      downloader.download
    end
  end
end
