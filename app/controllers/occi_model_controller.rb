# Controller class handling all model-related requests.
# Implements listing of resources, retrieval of the model
# and creation/deletion of mixins.
require 'rubygems'
require 'occi-api'

ONE_ENDPOINT           = 'https://172.90.0.10:11443'
ONE_USERNAME = 'rocci'
ONE_PASSWORD = 'rocci'


EC2_ENDPOINT           = 'https://172.90.0.20:11443'
EC2_USERNAME = 'AKIAJFZHTZ44OBT26KSQ'
EC2_PASSWORD = 'mhwP6HbIW8EODHD+VUcS6859CShPWmsFK6KqRbVM'


OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
class OcciModelController < ApplicationController
  # GET /
  def index
    if INDEX_LINK_FORMATS.include?(request.format)
      @resources = []

      @resources.concat(backend_instance.compute_list_ids.map { |c| "#{server_url}/compute/#{c}" })
      @resources.concat(backend_instance.network_list_ids.map { |n| "#{server_url}/network/#{n}" })
      @resources.concat(backend_instance.storage_list_ids.map { |s| "#{server_url}/storage/#{s}" })
      options = { flag: :links_only }
    else
      @resources = Occi::Collection.new

      @resources.resources.merge backend_instance.compute_list
      @resources.resources.merge backend_instance.network_list
      @resources.resources.merge backend_instance.storage_list
      options = {}
    end

    respond_with(@resources, options)
  end

  # GET /-/
  # GET /.well-known/org/ogf/occi/-/
  def show
    #@model = OcciModel.get(backend_instance, request_occi_collection)
    #respond_with(@model)
    
    #puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nListing all available resource types:"
    
    #puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nONE:"
    
    t = Time.now
    File.open("/opt/rOCCI-server/daniel.log", "a+") { |f| f.puts t.strftime("%H:%M:%S:%L") + " [daniel] occi_model_controller.rb, OcciModelController.show(), enter: " }
      
    
    

## get an OCCI::Api::Client::ClientHttp instance
one_client = Occi::Api::Client::ClientHttp.new({
  :endpoint => ONE_ENDPOINT,
  :auth => {
    :type               => "basic",
#    :user_cert          => USER_CERT,
#    :user_cert_password => USER_CERT_PASSWORD,
#    :ca_path            => CA_PATH
    :username           => ONE_USERNAME,
    :password => ONE_PASSWORD
  },
  :log => {
    :out   => STDERR,
    :level => Occi::Api::Log::DEBUG
  }
})



    
    one_client.get_resource_types.each do |type|
    puts "\n#{type}"
    end
    
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nEC2:"
    
    
ec2_client = Occi::Api::Client::ClientHttp.new({
  :endpoint => EC2_ENDPOINT,
  :auth => {
    :type               => "basic",
#    :user_cert          => USER_CERT,
#    :user_cert_password => USER_CERT_PASSWORD,
#    :ca_path            => CA_PATH
    :username           => EC2_USERNAME,
    :password => EC2_PASSWORD
  },
  :log => {
    :out   => STDERR,
    :level => Occi::Api::Log::DEBUG
  }
})

    
    ec2_client.get_resource_types.each do |type|
    puts "\n#{type}"
    end
    
    t = Time.now
    File.open("/opt/rOCCI-server/daniel.log", "a+") { |f| f.puts t.strftime("%H:%M:%S:%L") + " [daniel] occi_model_controller.rb, OcciModelController.show(), leave: " }
     
    
    
  end

  # POST /-/
  # POST /.well-known/org/ogf/occi/-/
  def create
    # TODO: impl
    collection = Occi::Collection.new
    respond_with(collection, status: 501)
  end

  # DELETE /-/
  # DELETE /.well-known/org/ogf/occi/-/
  def delete
    # TODO: impl
    collection = Occi::Collection.new
    respond_with(collection, status: 501)
  end
end
