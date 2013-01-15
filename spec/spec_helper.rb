# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
require 'vcr'
require 'rspec'
Dir[File.join(File.dirname(__FILE__), "spec/support/**/*.rb")].each {|f| require f}

VCR.configure do |c|
  c.cassette_library_dir     = 'spec/cassettes'
  c.hook_into                :webmock
  c.default_cassette_options = { :record => :new_episodes, :match_requests_on => [:method, :uri, :body]}
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
#  config.extend VCR::RSpec::Macros

  vcr_cassette_name_for = lambda do |metadata|
    description = metadata[:description]

    if example_group = metadata[:example_group]
      [vcr_cassette_name_for[example_group], description].join('/')
    else
      description
    end
  end

  config.around(:each) do |example|
    cassette_name = vcr_cassette_name_for[example.metadata]
    VCR.use_cassette(cassette_name, &example)
  end
end
