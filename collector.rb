require 'webmachine'
require 'logger'
require 'json'

$logger = Logger.new('headers.log')

class HeadersResource < Webmachine::Resource
  def finish_request
    $logger.info "\n#{JSON.pretty_generate(request.headers)}"
  end

  def to_html
    "<html><body>Thank you!</body></html>"
  end
end

Webmachine.application.routes do
  add ['collect'], HeadersResource
end

Webmachine.application.run
