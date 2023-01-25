# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'repo_downloader'
  spec.version       = '0.1.0'
  spec.authors       = ['Stanislav Dzisiak']
  spec.email         = ['stanislav.dzisiak@outlook.com']

  spec.summary       = 'Repositories downloader'
  spec.description   = 'CLI util for download repositories from Gitlab'
  spec.homepage      = 'https://gitlab.com/hexlethq/hexlet-exercise-kit'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.2')

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dotenv', '~> 2.7.6'
  spec.add_dependency 'git', '>= 1.9.1', '< 1.14.0'
  spec.add_dependency 'gitlab', '~> 4.17.0'
  spec.add_dependency 'mixlib-log', '~> 3.0.9'
  spec.add_dependency 'parallel', '~> 1.20.1'
  spec.add_dependency 'tty-cursor', '~> 0.7.1'
end
