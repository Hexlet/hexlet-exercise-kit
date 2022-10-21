# frozen_string_literal: true

require 'dotenv/load'

module RepoDownloader
  module Cli
    def self.run
      log_level = ENV['DEBUG'] == 'true' ? :debug : :info
      Log.level(log_level)

      options = {
        parallel: ENV.fetch('PARALLEL', 4).to_i,
        filter: ENV.fetch('FILTER', 'all').to_sym,
        update: ENV.fetch('UPDATE', 'false') == 'true',
        gitlab_endpoint: ENV.fetch('GITLAB_API_ENDPOINT'),
        gitlab_private_token: ENV.fetch('GITLAB_API_PRIVATE_TOKEN'),
        repos_path: File.expand_path('..', Dir.getwd)
      }

      raise 'You should to add Gitlab private token in .env file' if options[:gitlab_private_token].empty?
      raise 'You should to add Gitlab api endpoint in .env file' if options[:gitlab_endpoint].empty?

      downloader = RepoDownloader::Downloader.new(options)
      downloader.download
    end
  end
end
