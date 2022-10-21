# frozen_string_literal: true

require 'gitlab'
require 'git'
require 'parallel'
require 'benchmark'
require 'tty-cursor'

module RepoDownloader
  class Downloader
    def initialize(options = {})
      @options = options
      @tty_cursor = TTY::Cursor
      @errors = []

      regexp_filter_map = {
        courses: %r{^hexlethq/(courses)/(.+)$},
        exercises: %r{^hexlethq/(exercises)/(.+)$},
        programs: %r{^hexlethq/(programs)/(.+)$},
        projects: %r{^hexlethq/(projects)/(.+)$},
        all: %r{^hexlethq/(courses|exercises|programs|projects)/(.+)$}
      }

      @filter_regexp = regexp_filter_map.fetch(options[:filter])
    end

    def load_projects
      projects = []

      response = Gitlab.projects(per_page: 100)

      response.each_page do |current_projects|
        projects += current_projects
        print @tty_cursor.clear_line
        Log.info("received data on #{projects.length} repositories")
        print @tty_cursor.up
      end

      print @tty_cursor.down
      projects
    end

    def prepare_loaded_projects(projects)
      matched_projects = projects.select do |project|
        matches = project.path_with_namespace.match(@filter_regexp)
        project.path_with_namespace.match?(@filter_regexp) && !matches[2].match?(%r{^[^/]+/hexlet-groups/.+$})
      end

      matched_projects.map do |project|
        matches = project.path_with_namespace.match(@filter_regexp)

        {
          name: project.name,
          ssh_url: project.ssh_url_to_repo,
          path: File.join(@options[:repos_path], File.join(matches[1], matches[2]))
        }
      end
    end

    def make_error(error_type, path, url = '')
      { error_type:, url:, path: }
    end

    def get_error_message(error)
      if error[:error_type] == :clone
        "#{error[:error_type]} #{error[:url]} to #{error[:path]}"
      else
        "#{error[:error_type]} #{error[:path]}"
      end
    end

    def clone_repo(url, path)
      Git.clone(url, path)
    rescue StandardError
      make_error(:clone, path, url)
    end

    def update_repo(path)
      repo = Git.open(path)
      unless repo.current_branch.nil?
        repo.checkout('main')
        repo.pull('origin', repo.current_branch)
      end
    rescue StandardError
      make_error(:update, path)
    end

    def process_projects(projects)
      results = Parallel.map(projects, in_processes: @options[:parallel], progress: 'Processing projects') do |project|
        if !File.directory?(project[:path])
          clone_repo(project[:ssh_url], project[:path])
        elsif @options[:update]
          update_repo(project[:path])
        end
      end
      @errors += results.filter { |el| el.is_a?(Hash) && el.key?(:error_type) }
    end

    def download
      Log.info('Begin fetching repositories list')
      projects = prepare_loaded_projects(load_projects)
      Log.info("Found #{projects.length} projects")
      puts

      Log.info('Projects processing started')
      process_time = Benchmark.measure do
        process_projects(projects)
      end
      puts

      @errors.each do |error|
        Log.error(get_error_message(error))
      end
      puts if @errors.any?

      ms = (process_time.real * 1000).round
      seconds = (ms / 1000 % 60).to_s.rjust(2, '0')
      minutes = (ms / (1000 * 60) % 60).to_s.rjust(2, '0')
      hours = (ms / (1000 * 60 * 60)).to_s.rjust(2, '0')

      message = if @errors.any?
                  'Projects process completed with errors. See above.'
                else
                  'Projects process completed successfully'
                end

      Log.info(message)
      Log.info("Total: #{projects.length} projects")
      Log.info("Elapsed time: #{hours}:#{minutes}:#{seconds}")
    end
  end
end
