require 'faraday'
class Crowd::Client::Logger < Faraday::Response::Middleware
  extend Forwardable

 def initialize(app, logger = nil)
    super(app)
    @logger = logger || begin
      require 'logger'
      ::Logger.new(STDOUT)
    end
  end

  def_delegators :@logger, :debug, :info, :warn, :error, :fatal

  def call(env)
    info "#{env[:method]} #{env[:url].to_s}"
    debug "------ Request ------\n#{dump_headers env[:request_headers]}\nBody: #{env[:body]}"
    super
  end

  def on_complete(env)
    info "Status: #{env[:status].to_s}"
    debug "------ Response ------\n#{dump_headers env[:response_headers]}\nBody: #{env[:response].body}"
  end

  private
    def dump_headers(headers)
      headers.map { |k, v| "#{k}: #{v.inspect}" }.join("\n")
    end
end
