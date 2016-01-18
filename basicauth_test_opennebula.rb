#!/usr/bin/env ruby

#require 'rubygems'
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


OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

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

def show_resource_types()
  
  if nil == @one_client or nil == @ec2_client
    
    puts "nil client !"
    return
    
  end
  
  puts "\n\nListing all available resource types:"
  
  #puts "\n\nONE:\n\n"
  
  #t = Time.now
  #File.open("/opt/rOCCI-server/daniel.log", "a+") { |f| f.puts t.strftime("%H:%M:%S:%L") + " [daniel] occi_model_controller.rb, OcciModelController.show(), enter: " } 
    
  @one_client.get_resource_types.each do |type|
  puts "\n#{type}"
  end
  
  puts "\n\nEC2:\n\n"
  
  @ec2_client.get_resource_types.each do |type|
  puts "\n#{type}"
  end
  
  puts "\n\n"
  
  return
      
end

def list_ec2()
  
  #puts "\n\nListing one_client:"
  #prep_conn( "one" )
  
  #puts "\n\nbefore delete:"
  #@one_client.describe( "compute" ).each do |type|
    #puts "\n#{type}"
    #end
  
  #puts "\n\ngo to delete:"
  #@one_client.delete( "https://172.90.0.10:11443/compute/57" )
  
  #puts "\n\nafter delete:"
  #@one_client.describe( "storage" ).each do |type|
    #puts "\n#{type}"
    #end
  
  puts "\n\nListing ec2_client, get_resource_types:"
  prep_conn( "ec2" )
  @ec2_client.get_resource_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, client.get_mixin_types:"
  #prep_conn( "ec2" )
  @ec2_client.get_mixin_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, client.get_entity_types:"
  #prep_conn( "ec2" )
  @ec2_client.get_entity_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, client.get_link_types:"
  #prep_conn( "ec2" )
  @ec2_client.get_link_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, describe:"
  prep_conn( "ec2" )
  @ec2_client.describe( "compute" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, describe:"
  prep_conn( "ec2" )
  @ec2_client.describe( "storage" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, describe:"
  prep_conn( "ec2" )
  @ec2_client.describe( "network" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, get_mixins:"
  prep_conn( "ec2" )
  @ec2_client.get_mixins().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing ec2_client, get_link_type_identifiers:"
  prep_conn( "ec2" )
  @ec2_client.get_link_type_identifiers().each do |type|
    puts "\n#{type}"
  end
  
  
end

def list_one()
  
  #puts "\n\nListing one_client:"
  #prep_conn( "one" )
  
  #puts "\n\nbefore delete:"
  #@one_client.describe( "compute" ).each do |type|
    #puts "\n#{type}"
    #end
  
  #puts "\n\ngo to delete:"
  #@one_client.delete( "https://172.90.0.10:11443/compute/57" )
  
  #puts "\n\nafter delete:"
  #@one_client.describe( "storage" ).each do |type|
    #puts "\n#{type}"
    #end
  
  puts "\n\nListing @one_client, get_resource_types:"
  prep_conn( "one" )
  @one_client.get_resource_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, client.get_mixin_types:"
  #prep_conn( "ec2" )
  @one_client.get_mixin_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, client.get_entity_types:"
  #prep_conn( "ec2" )
  @one_client.get_entity_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, client.get_link_types:"
  #prep_conn( "ec2" )
  @one_client.get_link_types().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, describe:"
  #prep_conn( "ec2" )
  @one_client.describe( "compute" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, describe:"
  #prep_conn( "ec2" )
  @one_client.describe( "storage" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, describe:"
  #prep_conn( "ec2" )
  @one_client.describe( "network" ).each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, get_mixins:"
  #prep_conn( "ec2" )
  @one_client.get_mixins().each do |type|
    puts "\n#{type}"
  end
  
  puts "\n\nListing @one_client, get_link_type_identifiers:"
  #prep_conn( "ec2" )
  @one_client.get_link_type_identifiers().each do |type|
    puts "\n#{type}"
  end
  
  
end


def test_one()
  
  puts "\n\nListing one_client:"
  prep_conn( "one" )
  #puts @one_client.get_mixin_type_identifiers()
  #puts @one_client.list_mixin( "uuid_lab_occi_one_vm_template_p0_2" ).inspect
  #puts @one_client.get_action_type_identifiers().inspect
=begin
  #@one_client.list( "http://schemas.ogf.org/occi/infrastructure#os_tpl" ).each do |type|
  @one_client.list_mixins().each do |type|
    puts type.inspect
    puts "\n#{type}"
  end
=end
  
  #puts @one_client.list_mixin( "uuid_lab_occi_one_vm_template_p23_25" )
  #puts @one_client.get( "https://172.90.0.10:11443/storage/15" ).inspect
  
  #startaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#', term='start', title='start compute instance'
  #startactioninstance = Occi::Core::ActionInstance.new startaction, nil
  #stopaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#', term='stop', title='stop compute instance'
  #stopactioninstance = Occi::Core::ActionInstance.new stopaction, nil
  #
  #backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storage/action#', term='backup', title='backup storage'
  #backupactioninstance = Occi::Core::ActionInstance.new backupaction, nil
  


  #http://schemas.ogf.org/occi/infrastructure/storage/action#backup
  
  #puts @one_client.trigger( "https://172.90.0.10:11443/compute/59", stopactioninstance ).inspect
  #puts @one_client.trigger( "https://172.90.0.10:11443/compute/59", startactioninstance ).inspect
  #puts @one_client.trigger( "https://172.90.0.10:11443/storage/1", backupactioninstance ).inspect

  #puts @one_client.trigger( "https://172.90.0.10:11443/storage/1", backupactioninstance ).inspect
  
  #puts @one_client.delete( "https://172.90.0.10:11443/storage/36" ).inspect
  
  #http://occi.172.90.0.10/occi/infrastructure/os_tpl#uuid_lab_occi_one_vm_template_p0_2
  
  backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='clone', title='clone os_tpl'
  backupactioninstance = Occi::Core::ActionInstance.new backupaction, nil
  
  #puts @one_client.trigger( "https://172.90.0.10:11443/mixin/os_tpl/2", backupactioninstance ).inspect
  puts @one_client.trigger( "/mixin/os_tpl/2", backupactioninstance ).inspect
  
  
end

def get_latest_storage_id
  prep_conn( "one" )
  latest_id = @one_client.list( "storage" ).last.split("/").last.to_i
end

def get_latest_os_tpl_id
  prep_conn( "one" )
  latest_id = @one_client.list( "/mixin/os_tpl" ).last.split("/").last.to_i
  #puts @one_client.list( "/mixin/os_tpl" ).inspect
end

def clone_images_os_tpls
  
  source_img = "/storage/9"
  source_os_tpl = "/mixin/os_tpl/2"
  
  #s_new_id = get_latest_storage_id + 1
  #os_new_id = get_latest_os_tpl_id + 1
  
  for idx in 0..2 do
    puts "idx:" + idx.inspect
    #clone image /storage/9:ubuntu-occi-hd-4G-p
    s_backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storage/action#', term='backup', title='backup storage'
    s_backupactioninstance = Occi::Core::ActionInstance.new s_backupaction, nil
    @one_client.trigger( source_img, s_backupactioninstance )
    
    os_backupaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='clone', title='clone os_tpl'
    os_backupactioninstance = Occi::Core::ActionInstance.new os_backupaction, nil
    @one_client.trigger( source_os_tpl, os_backupactioninstance )
    
  end
  

  
  
  #@one_client.trigger( "/mixin/os_tpl/#{}", os_backupactioninstance )
  
  s_new_id = get_latest_storage_id() - 2
  os_new_id = get_latest_os_tpl_id() - 2
  
  #s_state = "online"
  puts "s_new_id:" + s_new_id.inspect
  puts "os_new_id:" + os_new_id.inspect
  
  
  s_states = [ "offline", "offline", "offline" ]
  os_states = [ "draft", "draft", "draft" ]
  #s_states = []
  
  
  os_updateaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='update', title='update os_tpl'
  
  os_instaction = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/os_tpl/action#', term='instantiate', title='instantiate os_tpl'
  os_instactioninstance = Occi::Core::ActionInstance.new os_instaction, nil
  
  begin
    for idx in 0..2 do
      
      puts "idx:" + idx.inspect
      
      s_id = s_new_id + idx
      os_id = os_new_id + idx
      
      if "offline" == s_state[idx] then
        s_state[idx] = @one_client.get("/storage/#{s_id}").resources.first.attributes.occi.storage.state
        puts "/storage/" + s_id.inspect + " state: " + s_states[idx]
      else
        if "draft" = os_states[idx] then
          
          os_updateactioninstance = Occi::Core::ActionInstance.new os_updateaction, "DISK = [ IMAGE_ID = #{s_id} ]"
          rc = @one_client.trigger( "/mixin/os_tpl/#{os_id}", os_updateactioninstance )
          if rc then os_states[idx] = "updated"
          
        elsif "updated" == os_states[idx]
          #updated
          #go to instantiate
          rc = @one_client.trigger( "/mixin/os_tpl/#{os_id}", os_instactioninstance )
          if rc then os_states[idx] = "instantiated"
          
        end
      end
      
    end
    # ?
  end until [ "instantiated", "instantiated", "instantiated" ] == os_states
  
  puts "all os instantiated cloned."
    
end




#init_clients()
init_client( "one" )
#show
#test()
#list_ec2()
#list_one()
#test_one()
#get_latest_storage_id
#puts @one_client.get("/storage/9").resources.first.attributes.occi.storage.state.inspect
clone_images_os_tpls()
#get_latest_os_tpl_id.inspect


