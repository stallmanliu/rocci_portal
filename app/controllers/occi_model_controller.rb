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
#AKIAJ27CLZF7UKE66G7A:l2a0ng4T53o4NXUdQuyhBnewXPY0udZDMs8Qcncl
EC2_USERNAME = 'AKIAJ27CLZF7UKE66G7A'
EC2_PASSWORD = 'l2a0ng4T53o4NXUdQuyhBnewXPY0udZDMs8Qcncl'
#default deployment: one/ec2 ratio, e.g: 0.5, 0.75, 1.0, 2.0, 5.0
@@one_ec2_ratio = 3
@@vm_num_one = 0
@@vm_num_ec2 = 0


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
  
  def deploy( deploy_type, vm_num )
    
    puts "deploy_type:" + deploy_type.inspect + ", vm_num:" + vm_num.inspect
    
    case deploy_type
      
    when "Default"
      
      #default deployment: one/ec2 ratio
      @@one_ec2_ratio = @@one_ec2_ratio.to_f
      @@vm_num_one = ( vm_num * ( @@one_ec2_ratio / ( @@one_ec2_ratio + 1 ) ) ).round
      @@vm_num_ec2 = vm_num - @@vm_num_one
      
    when "OpenNebula"
      
      @@vm_num_one = vm_num
      @@vm_num_ec2 = 0
      
    when "Amazon EC2"
      
      @@vm_num_one = 0
      @@vm_num_ec2 = vm_num
      
    else
      
      puts "wrong deploy_type input !"
      
    end
    
    puts "deploy: one:" + @@vm_num_one.inspect + ", ec2:" + @@vm_num_ec2.inspect
  
  end

  def create_vms_one
  
    source_img = "/storage/863"
    source_os_tpl = "/mixin/os_tpl/5"
  
    #s_new_id = get_latest_storage_id + 1
    #os_new_id = get_latest_os_tpl_id + 1
    #s_new_id = get_latest_storage_id() + 1
  
    prep_conn( "one" )
    for idx in 0..(@@vm_num_one - 1) do
      puts "idx:" + idx.inspect
      #s_id = s_new_id + idx
      #clone image /storage/9:ubuntu-occi-hd-4G-p
      s_backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storage/action#', term='backup', title='backup storage'
      s_backupactioninstance = Occi::Core::ActionInstance.new s_backupaction, nil
      #puts source_img + " state:" + @one_client.get( source_img ).resources.first.attributes.occi.storage.state
      #sleep 1
      rc = @one_client.trigger( source_img, s_backupactioninstance )
      puts "clone image + 1, result:" + rc.inspect
      #puts "clone + 1, " + source_img + " state:" + @one_client.get( source_img ).resources.first.attributes.occi.storage.state
    
      #os_backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='clone', title='clone os_tpl'
      #os_backupactioninstance = Occi::Core::ActionInstance.new os_backupaction, nil
      #puts source_os_tpl + " state:" + @one_client.get( source_os_tpl ).resources.first.attributes.occi.storage.state
      #@one_client.trigger( source_os_tpl, os_backupactioninstance )
  
      os_updateaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='update', title='update os_tpl'
      s_id = get_latest_storage_id
      puts "get latest_storage_id:" + s_id.inspect
      hash = { :occi => { :infrastructure => { :os_tpl => { :image_id => "#{s_id}" } } } }
      os_updateactioninstance = Occi::Core::ActionInstance.new os_updateaction, hash
      #puts os_updateactioninstance.inspect
      rc = @one_client.trigger( source_os_tpl, os_updateactioninstance )
      #rc = @one_client.trigger( "/mixin/os_tpl/#{os_id}", os_updateactioninstance )
      puts "update os_tpl, result:" + rc.inspect
    
      while "online" != @one_client.get("/storage/#{s_id}").resources.first.attributes.occi.storage.state do
        sleep 5
      end
  
      os_instaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='instantiate', title='instantiate os_tpl'
      os_instactioninstance = Occi::Core::ActionInstance.new os_instaction, nil

      rc = @one_client.trigger( source_os_tpl, os_instactioninstance )
      puts "instantiate os_tpl, result:" + rc.inspect
    
    end
  
    puts "all vm created."
  
  end

  def check_vms_one
    
    cmpt_data = @one_client.list("compute")
  
    puts "cmpt_data:" + cmpt_data.inspect
  
    cmpt_sub = []
  
    for i in 0..(@@vm_num_one -1) do
      cmpt_sub[i] = cmpt_data[cmpt_data.length - @@vm_num_one + i].split("/").last
      #puts @one_client.get("/compute/#{cmpt_sub[i]}").inspect
    end
  
    puts "cmpt_sub:" + cmpt_sub.inspect
  
    c_states = Array.new( @@vm_num_one, "inactive" )
    c_states_f = Array.new( @@vm_num_one, "active" )
  
    begin
  
      for idx in 0..(@@vm_num_one - 1) do
        c_id = cmpt_sub[idx]
        c_states[idx] = @one_client.get("/compute/#{c_id}").resources.first.attributes.occi.compute.state
        #c_states[idx] = cmpt_sub[idx].attributes.occi.compute.state
        puts "state of vm" + idx.inspect + ":" + c_states[idx].inspect
      end
    
      sleep 1
    
    end until c_states_f == c_states
  
    puts "all vm running."
  
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
      prep_conn( "one" )
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
      prep_conn( "ec2" )
    end

    if INDEX_LINK_FORMATS.include?(request.format)
      #@computes ||= @ec2_client.list( "compute" )
      #@computes.map! { |c| "#{server_url}/compute/#{c}" }
      #options = { flag: :links_only }
      puts "@ec2_client.list( compute ):" + @ec2_client.list( "compute" ).inspect
    else
      #@computes = Occi::Collection.new
      @computes.resources.merge @ec2_client.describe( "compute" )
      #update_mixins_in_coll(@computes)
      #options = {}

      #puts "@ec2_client.describe( compute ):" + @ec2_client.describe( "compute" ).inspect
    end
    
    #puts "@computes:" + @computes.inspect
    
    #@computes = @one_client.list( "compute" )
    #@computes.map! { |c| "#{server_url}/compute/#{c}" }
    #options = { flag: :links_only }

    #respond_with(@computes, options)
    
  end
  
  #GET /new_simulation
  def new_simulation
  
    puts "daniel: new_simulation"
    
  end
  
  #POST /new_simulation
  def new_simulation_submit
  
    puts "daniel: new_simulation_submit"
    
    #puts "params:" + params[:deploy_type].inspect + ". end"
    
    deploy_type = params[:deploy_type]
    vm_num = params[:vm_num].to_i
    
    deploy( deploy_type, vm_num )
    create_vms_one()
    #check_vms_one()
    
    
  end
  
  def management
    
    puts "daniel: management"
    
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
