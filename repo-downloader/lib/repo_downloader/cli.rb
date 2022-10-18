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

      downloader = RepoDownloader::Downloader.new({
                                                    parallel: ENV.fetch('PARALLEL', nil),
                                                    filter: ENV.fetch('FILTER', nil),
                                                    repos_path: ENV.fetch('PATH_TO_REPOS', nil),
                                                    update: ENV.fetch('UPDATE', nil)
                                                  })

      downloader.download
    end
  end
end
