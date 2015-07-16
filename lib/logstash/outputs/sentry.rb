# encoding: utf-8
require 'logstash/outputs/base'
require 'logstash/namespace'
require 'json'

class LogStash::Outputs::Sentry < LogStash::Outputs::Base
 
  config_name 'sentry'
   
  config :key, :validate => :string, :required => true
  config :secret, :validate => :string, :required => true
  config :project_id, :validate => :string, :required => true
  config :host, :validate => :string, :default => "https://app.getsentry.com", :required => false 
  config :msg, :validate => :string, :default => "Message from logstash", :required => false
  config :level_tag, :validate => :string, :default => "error", :required => false
  config :use_ssl, :validate => :boolean, :default => true, :required => false 
  config :fields_to_tags, :validate => :boolean, :default => false, :required => false

  public
  def register
    require 'net/https'
    require 'uri'
    
    @url = "#{host}/api/#{project_id}/store/"
    @uri = URI.parse(@url)

    @client = Net::HTTP.new(@uri.host, @uri.port)
    @client.use_ssl = use_ssl
    @client.verify_mode = OpenSSL::SSL::VERIFY_NONE
 
   @logger.debug("Client", :client => @client.inspect)
  end
 
  public
  def receive(event)
    return unless output?(event)
 
    require 'securerandom'
 
    packet = {
      :event_id => SecureRandom.uuid.gsub('-', ''),
      :timestamp => event['@timestamp'],
      :message => "#{msg}"
   }

    packet[:level] = "#{level_tag}" 
    packet[:platform] = 'logstash'
    packet[:server_name] = event['host']    
    packet[:extra] = event.to_hash   
   
    if fields_to_tags == true 
       packet[:tags] = event.to_hash
    end 

    @logger.debug("Sentry packet", :sentry_packet => packet)
 
    auth_header = "Sentry sentry_version=5," +
      "sentry_client=raven_logstash/1.0," +
      "sentry_timestamp=#{event['@timestamp'].to_i}," +
      "sentry_key=#{@key}," +
      "sentry_secret=#{@secret}"
 
    request = Net::HTTP::Post.new(@uri.path)
 
    begin
      request.body = packet.to_json
      request.add_field('X-Sentry-Auth', auth_header)
 
      response = @client.request(request)
 
      @logger.info("Sentry response", :request => request.inspect, :response => response.inspect)
 
      raise unless response.code == '200'
    rescue Exception => e
      @logger.warn("Unhandled exception", :request => request.inspect, :response => response.inspect, :exception => e.inspect)
    end
  end
end

