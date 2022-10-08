# frozen_string_literal: true

require 'gitlab'
require 'git'
require 'parallel'
require 'benchmark'

module RepoDownloader
  class Downloader
    def initialize(options = {})
      @parallel = options[:parallel].nil? ? 8 : options[:parallel].to_i

      filter = options[:filter].nil? ? 'all' : options[:filter]
      @filter_regexp =
        case filter
          when 'courses'
            /^hexlethq\/(courses)\/(.+)$/
          when 'exercises'
            /^hexlethq\/(exercises)\/(.+)$/
          when 'programs'
            /^hexlethq\/(programs)\/(.+)$/
          when 'projects'
            /^hexlethq\/(projects)\/(.+)$/
          when 'all'
            /^hexlethq\/(courses|exercises|programs|projects)\/(.+)$/
          else
            raise "Unknown filter: #{filter}"
        end

      @repos_path =
        if options[:repos_path].nil?
          File.expand_path('..', Dir.getwd)
        else
          File.expand_path(options[:repos_path])
        end

      @update = options[:update] == 'true'
    end

    def loadProjectsList
      projects = []
      page = 1

      loop do
        projects_per_page = Gitlab.projects({
          per_page: 100,
          page: page,
          visibility: :private,
          simple: true,
        })

        projects += projects_per_page
        print "\033[K"
        Log.info("received data on #{projects.length} repositories")
        print "\033[A\r"

        break if projects_per_page.length == 0

        page += 1
      end

      projects
        .select do |project|
          matches = project.path_with_namespace.match(@filter_regexp)
          project.path_with_namespace.match?(@filter_regexp) && !matches[2].match?(/^[^\/]+\/hexlet-groups\/.+$/)
        end
        .map do |project|
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
      Parallel.map(projects, in_processes: @parallel) do |project|
        action = nil
        time = Benchmark.measure do
          action =
            if !File.directory?(project[:path])
              Git.clone(project[:ssh_url], project[:path])
              'cloned'
            elsif @update
              repo = Git.open(project[:path])
              if repo.current_branch.nil?
                'skiped'
              else
                repo.pull('origin', repo.current_branch)
                'updated'
              end
            else
              'skiped'
            end
        end
        ms = (time.real * 1000).round
        print "\033[K"
        Log.info("#{action} #{project[:name]} +#{ms}ms")
        print "\033[A\r"
      end
    end

    def download
      Log.info('Loading projects list')
      projects = loadProjectsList
      print "\033[B"
      Log.info("Finded #{projects.length} projects")

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
