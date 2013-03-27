require 'httpclient'
require 'pathname'
require 'json'

user = ENV['BROWSERSTACK_USER']
pass = ENV['BROWSERSTACK_PASS']
url  = ENV['BROWSERSTACK_URL']

class BrowserStackClient

  attr_reader :http

  def initialize(user, pass)
    @user = user
    @pass = pass
    @root = Pathname.new('http://api.browserstack.com/3')
    @http = HTTPClient.new
    @http.set_auth(@root.to_s, @user, @pass)
  end

  def available_browsers
    response = http.get(@root.join('browsers?flat=true'))
    JSON.parse(response.body)
  end

  def spawn_worker(url, params)
    response = http.post(@root.join('worker'), params.merge(url: url))
    JSON.parse(response.body)["id"]
  end

  def worker_status(id)
    response = http.get(@root.join('worker', id.to_s))
    JSON.parse(response.body)["status"]
  end

  def terminate_worker(id)
    http.delete(@root.join('worker', id.to_s))
  end
end

client = BrowserStackClient.new(user, pass)
puts "---> awesome, %s browsers to test" % client.available_browsers.count

client.available_browsers.each_with_index do |browser, index|
  id = client.spawn_worker(url, browser)
  sleep(1) while client.worker_status(id) == "queue"
  puts "---> worker #{index} status is #{client.worker_status(id)}, terminating"
  client.terminate_worker(id)
end
