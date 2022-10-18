# frozen_string_literal: true

require 'gitlab'
require 'git'
require 'parallel'
require 'benchmark'

module RepoDownloader
  class Downloader
    DEFAULT_PARALLELS = 4
    def initialize(options = {})
      @parallel = options.fetch(:parallel, DEFAULT_PARALLELS).to_i
      @update = options[:update] == 'true'
      @repos_path =
        if options[:repos_path].nil?
          File.expand_path('..', Dir.getwd)
        else
          File.expand_path(options[:repos_path])
        end

      filter = options.fetch(:filter, :all).to_sym

      regexp_filter_map = {
        courses: %r{^hexlethq/(courses)/(.+)$},
        exercises: %r{^hexlethq/(exercises)/(.+)$},
        programs: %r{^hexlethq/(programs)/(.+)$},
        projects: %r{^hexlethq/(projects)/(.+)$},
        all: %r{^hexlethq/(courses|exercises|programs|projects)/(.+)$}
      }

      raise "Unknown filter: #{filter}" unless regexp_filter_map.key?(filter)

      @filter_regexp = regexp_filter_map.fetch(filter)
    end

    def load_projects
      projects = []

      response = Gitlab.projects({
                                   per_page: 100,
                                   visibility: :private,
                                   simple: true
                                 })

      response.each_page do |current_projects|
        projects += current_projects
        print "\033[K"
        Log.info("received data on #{projects.length} repositories")
        print "\033[A\r"
      end

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
          path: File.join(@repos_path, File.join(matches[1], matches[2]))
        }
      end
    end

    # TODO: simplify method logic,
    # add error handle,
    # add logging to file if error
    def process_projects(projects)
      Parallel.each(projects, in_processes: @parallel, progress: 'Processing projects') do |project|
        action = nil
        time = Benchmark.measure do
          action =
            if !File.directory?(project[:path])
              Git.clone(project[:ssh_url], project[:path])
              'cloned'
            elsif @update
              repo = Git.open(project[:path])
              if repo.current_branch.nil?
                'skipped'
              else
                repo.checkout('main')
                repo.pull('origin', repo.current_branch)
                'updated'
              end
            else
              'skipped'
            end
        end
        ms = (time.real * 1000).round
        print "\033[K"
        Log.info("#{action} #{project[:name]} +#{ms}ms")
        print "\033[A\r"
      end
    end

    def download
      Log.info('Begin fetching repositories list')
      projects = prepare_loaded_projects(load_projects)
      print "\033[B"
      Log.info("Found #{projects.length} projects")

      Log.info('Projects processing started')
      process_time = Benchmark.measure do
        process_projects(projects)
      end
      print "\033[K"

      ms = (process_time.real * 1000).round
      seconds = (ms / 1000 % 60).to_s.rjust(2, '0')
      minutes = (ms / (1000 * 60) % 60).to_s.rjust(2, '0')
      hours = (ms / (1000 * 60 * 60)).to_s.rjust(2, '0')

      Log.info('Projects process completed successfully')
      Log.info("Total: #{projects.length} projects")
      Log.info("Elapsed time: #{hours}:#{minutes}:#{seconds}")
    end
  end
end
