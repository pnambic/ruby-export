require 'rake'

Gem::Specification.new do |spec|
  spec.name = 'ruby_export'
  spec.version = '0.1.1'
  spec.summary = 'Export Ruby components for DepAn analysis'
  spec.description = 'Export Ruby components for DepAn analysis'
  spec.authors = ['Lee Carver']
  spec.email = 'leeca@pnambic.com'
  spec.homepage = 'https://github.com/pnambic/ruby-export'
  spec.license = 'Apache-2.0'
  spec.files = FileList['lib/*.rb', 'lib/*/*.rb']
end
