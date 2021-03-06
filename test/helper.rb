require 'simplecov'

module SimpleCov::Configuration
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
  load_adapter 'test_frameworks'
end

ENV["COVERAGE"] && SimpleCov.start do
  add_filter "/.rvm/"
end
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/autorun'
require 'minitest/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lipstick'

require 'yaml'

module Lipstick
  module Fixtures
    HOME_DIR = RUBY_PLATFORM =~ /mswin32/ ? ENV['HOMEPATH'] : ENV['HOME'] unless defined?(HOME_DIR)
    LOCAL_CREDENTIALS = File.join(HOME_DIR.to_s, '.lipstick/fixtures.yml') unless defined?(LOCAL_CREDENTIALS)

    def address(prefix, options = {})
      {
        "#{prefix}Address1" => '1234 My Street',
        "#{prefix}Address2" => 'Apt 1',
        "#{prefix}City"     => 'Ottawa',
        "#{prefix}State"    => 'ON',
        "#{prefix}Zip"      => 'K1C2N6',
        "#{prefix}Country"  => 'CA',
      }.update(options)
    end

    def all_fixtures
      @@fixtures ||= load_fixtures
    end

    def fixtures(key)
      data = all_fixtures[key] || raise(StandardError, "No fixture data was found for '#{key}'")
      data.dup
    end

    def load_fixtures
      [LOCAL_CREDENTIALS].inject({}) do |credentials, file_name|
        if File.exist?(file_name)
          yaml_data = YAML.load(File.read(file_name))
          credentials.merge!(symbolize_keys(yaml_data))
        end
        credentials
      end
    end

    def symbolize_keys(hash)
      return hash unless hash.is_a?(Hash)
      hash.each_with_object({}){|(k,v), h| h[k.to_sym] = symbolize_keys(v)}
    end
  end
end

def context(*args, &block)
  describe(*args, &block)
end

Minitest.autorun
