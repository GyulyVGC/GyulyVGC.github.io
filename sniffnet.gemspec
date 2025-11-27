# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "sniffnet"
  spec.version       = "1.0.0"
  spec.authors       = ["Giuliano Bellini"]
  spec.email         = ["gyulyvgc99@gmail.com"]

  spec.summary       = "Sniffnet is a cross-platform application to help you comfortably monitor your Internet traffic."
  spec.homepage      = "https://www.sniffnet.app"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(assets|_layouts|_includes|LICENSE|README|feed|404|_data|tags|staticman)}i) }

  spec.metadata      = {
    "changelog_uri"     => "https://github.com/GyulyVGC/sniffnet/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://github.com/GyulyVGC/sniffnet/wiki"
  }

  spec.add_runtime_dependency "jekyll", ">= 3.9"
  spec.add_runtime_dependency "jekyll-paginate", "~> 1.1"
  spec.add_runtime_dependency "jekyll-sitemap", "~> 1.4"
  spec.add_runtime_dependency "kramdown-parser-gfm", "~> 1.1"
  spec.add_runtime_dependency "kramdown", "~> 2.3"
end
