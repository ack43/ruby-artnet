require File.expand_path('../lib/art_net/version', __FILE__)

spec = Gem::Specification.new do |s|
  s.name = 'artnet'
  s.version = ArtNet::VERSION
  s.date = '2021-05-24'
  s.summary = 'Pure Ruby implementation of the Art-Net lighting protocol'
  s.email = "dev@redrocks.pro"
  s.homepage = "https://github.com/ack43/ruby-artnet/"
  s.description = "Pure Ruby implementation of the Art-Net lighting protocol"
  s.has_rdoc = false
  s.rdoc_options = '--include=examples'

  # ruby -rpp -e' pp `git ls-files`.split("\n").grep(/^(doc|README)/) '
  #s.extra_rdoc_files = [
  #  "README"
  #]
  s.add_development_dependency 'rspec', '~> 2.12'
  s.add_development_dependency 'autotest', '~> 4.4'

  # s.add_dependency 'async-io'

  s.authors = ["Alexander Kiseliev", "Sen"]

  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
end
