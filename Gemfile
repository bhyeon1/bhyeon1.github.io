# frozen_string_literal: true

source "https://rubygems.org"
gemspec

# Ruby 3.5 대응용 기본 gem 추가
gem 'logger'
gem 'fiddle'

# Windows 플랫폼에서 자동 재빌드를 위한 감시자 gem
gem 'wdm', '>= 0.1.0', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.6"
  gem "jekyll-sitemap"
  gem "jekyll-paginate"
  gem "jekyll-seo-tag"
  gem 'jekyll-redirect-from'
end