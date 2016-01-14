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
=begin
  @one_client.list( "http://schemas.ogf.org/occi/infrastructure#storage" ).each do |type|
    puts type.inspect
    puts "\n#{type}"
  end
=end
  
  #puts @one_client.list_mixin( "uuid_lab_occi_one_vm_template_p23_25" )
  puts @one_client.get( "https://172.90.0.10:11443/storage/15" ).inspect
  
end



#init_clients()
init_client( "one" )

#show
#test()
#list_ec2()
#list_one()
test_one()


