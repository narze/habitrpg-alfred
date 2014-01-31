#!/usr/bin/env ruby
# encoding: utf-8

($LOAD_PATH << File.expand_path("..", __FILE__)).uniq!

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "bundle/bundler/setup"
require "alfred"
require 'uri'
require 'net/http'
require 'net/https'
require 'json'

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback

  file = File.new("user.txt", "r")
  api_user = file.gets.chomp
  api_key = file.gets.chomp

  uri = URI.parse("https://beta.habitrpg.com:443/api/v2/user")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  req = Net::HTTP::Get.new(uri.path)
  req['x-api-user'] = api_user
  req['x-api-key'] = api_key
  res = https.request(req)
  user = JSON.parse(res.body)
  hp = user["stats"]["hp"]
  exp = user["stats"]["exp"]

  # add a file feedback
  fb.add_file_item(File.expand_path "~/Applications/")

  # add an arbitrary feedback
  fb.add_item({
    :uid      => ""                     ,
    :title    => "HP : #{hp} EXP : #{exp}"         ,
    :subtitle => "HabitRPG"        ,
    :arg      => "HP : #{hp} EXP : #{exp}" ,
    :valid    => "yes"                  ,
  })

  # add an feedback to test rescue feedback
  fb.add_item({
    :uid          => ""                     ,
    :title        => "Rescue Feedback Test" ,
    :subtitle     => "rescue feedback item" ,
    :arg          => ""                     ,
    :autocomplete => "failed"               ,
    :valid        => "no"                   ,
  })

  if ARGV[0].eql? "failed"
    alfred.with_rescue_feedback = true
    raise Alfred::NoBundleIDError, "Wrong Bundle ID Test!"
  end

  puts fb.to_xml(ARGV)
end



