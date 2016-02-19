# Controller class handling all model-related requests.
# Implements listing of resources, retrieval of the model
# and creation/deletion of mixins.

#first version

require 'rubygems'
require 'occi-api'
#require 'pp'

## options
use_os_temlate = true         # use OS_TEMPLATE or NETWORK + STORAGE + INSTANCE TYPE
OS_TEMPLATE    = 'monitoring' # name of the VM template in ON

clean_up_compute = true       # issue DELETE <RESOURCE> after we are done

USER_CERT          = ENV['HOME'] + '/.globus/usercred.pem'
USER_CERT_PASSWORD = 'mypassphrase'
CA_PATH            = '/etc/grid-security/certificates'

ONE_ENDPOINT           = 'https://172.90.0.10:11443'
ONE_USERNAME = 'rocci'
ONE_PASSWORD = 'rocci'

EC2_ENDPOINT           = 'https://172.90.0.20:11443'
#stallmanliu
#EC2_USERNAME = 'AKIAJFZHTZ44OBT26KSQ'
#EC2_PASSWORD = 'mhwP6HbIW8EODHD+VUcS6859CShPWmsFK6KqRbVM'
#daniel
EC2_USERNAME = 'AKIAJVCAU7L335Q2E4OQ'
EC2_PASSWORD = '3sJ7xNMiSmiywEaZJDANSzSckbOnorxrvHlrPkko'
@@vm_num = 2


OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


class OcciModelController < ApplicationController

  def init_clients()
    #@one_client = init_client( "one" )
    init_client( "one" )
    #@ec2_client = init_client( "ec2" )
    init_client( "ec2" )
  end

  def prep_conn( connect_type )
  
    case connect_type
    
    when "one"
    
      if nil == @one_client
        puts "nil @one_client !"
        return
      end

      @one_client.class.base_uri( ONE_ENDPOINT )
      @one_client.class.basic_auth( ONE_USERNAME, ONE_PASSWORD )
    
    when "ec2"
    
      if nil == @ec2_client
        puts "nil @@ec2_client !"
        return
      end

      @ec2_client.class.base_uri( EC2_ENDPOINT )
      @ec2_client.class.basic_auth( EC2_USERNAME, EC2_PASSWORD )
    
    else
    
      puts "wront client_type input !"
    
    end
  
    return
  
  end

  def init_client( client_type )
  
    #puts "client_type:" + client_type.inspect
  
    case client_type
    
    when "one"
    
      #puts "case: one"
    
      @one_client = Occi::Api::Client::ClientHttp.new({
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
          :level => Occi::Api::Log::WARN
        }
      })
    
    when "ec2"
    
      #puts "case: ec2"
    
      @ec2_client = Occi::Api::Client::ClientHttp.new({
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
          :level => Occi::Api::Log::WARN
        }
      })
    
    else
    
      #puts "wront client_type input !"
      #client = nil
    
    end
  
    #puts "client.endpoint:" + client.endpoint.inspect
  
    #client
    return
  
  end
  
  # DEFAULT
  # GET /
  def welcome
    #puts "daniel: occi_model#welcome"    
  end
  
  #GET /overview
  def overview
  
    if nil == @one_client
      puts "nil @one_client !"
      init_client( "one" )
    end
    
    #@computes = @one_client.list( "compute" )
    #@computes.map! { |c| "#{server_url}/compute/#{c}" }
    #options = { flag: :links_only }

    if INDEX_LINK_FORMATS.include?(request.format)
      @computes = @one_client.list( "compute" )
      #@computes.map! { |c| "#{server_url}/compute/#{c}" }
      #options = { flag: :links_only }
    else
      @computes = Occi::Collection.new
      @computes.resources = @one_client.describe( "compute" )
      #update_mixins_in_coll(@computes)
      #options = {}
    end
    
    if nil == @ec2_client
      puts "nil @ec2_client !"
      init_client( "ec2" )
    end

    if INDEX_LINK_FORMATS.include?(request.format)
      @computes ||= @ec2_client.list( "compute" )
      @computes.map! { |c| "#{server_url}/compute/#{c}" }
      options = { flag: :links_only }
    else
      #@computes = Occi::Collection.new
      @computes.resources ||= @ec2_client.describe( "compute" )
      #update_mixins_in_coll(@computes)
      options = {}
    end
    
    #@computes = @one_client.list( "compute" )
    #@computes.map! { |c| "#{server_url}/compute/#{c}" }
    #options = { flag: :links_only }

    #respond_with(@computes, options)
    
  end
  
  # GET /
  def index
    #puts "daniel: occi_model#index"
  
    if nil == @one_client
      puts "nil @one_client !"
      init_client( "one" )
    end

    
    #@resources = @computes
    
=begin    
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
=end

    #respond_with(@resources, options)
    #@resources = @one_client.list( "compute" )
    
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
      
    
    
=begin

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
=end
    
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
