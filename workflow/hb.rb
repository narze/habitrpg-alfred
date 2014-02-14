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

def add_user_status_feedback(fb)
  file = File.new("user.txt", "r")
  api_user = file.gets.chomp
  api_key = file.gets.chomp

  uri = URI.parse("https://habitrpg.com:443/api/v2/user")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  req = Net::HTTP::Get.new(uri.path)
  req['x-api-user'] = api_user
  req['x-api-key'] = api_key
  res = https.request(req)
  user = JSON.parse(res.body)
  hp = user["stats"]["hp"]
  exp = user["stats"]["exp"]

  # add an arbitrary feedback
  fb.add_item({
    :uid      => ""                     ,
    :title    => "HP : #{hp.round} EXP : #{exp.round}"         ,
    :subtitle => "HabitRPG"        ,
    :arg      => "HP : #{hp.round} EXP : #{exp.round}" ,
    :valid    => "yes"                  ,
  })

  fb
end

def add_tasks_feedback(fb)

  file = File.new("user.txt", "r")
  api_user = file.gets.chomp
  api_key = file.gets.chomp

  uri = URI.parse("https://habitrpg.com:443/api/v2/user/tasks")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  req = Net::HTTP::Get.new(uri.path)
  req['x-api-user'] = api_user
  req['x-api-key'] = api_key
  res = https.request(req)
  tasks = JSON.parse(res.body)

  tasks.each do |task|
    fb.add_item({
      :uid      => ""                     ,
      :title    => "[#{task["type"]}] #{task["text"]}"         ,
      :subtitle => ""        ,
      :arg      => "" ,
      :valid    => "yes"                  ,
    })
  end

  fb
end
Alfred.with_friendly_error do |alfred|

  alfred.with_rescue_feedback = true
  alfred.with_cached_feedback do
    # expire in 1 hour
    use_cache_file :expire => 3600
    # or define your own cache file
    # use_cache_file(
    #   :file   => File.join(alfred.volatile_storage_path ,"this_workflow.alfred2feedback") ,
    #   :expire => 3600
    # )

  end

  # prepend ! in query to refresh
  is_refresh = false
  if ARGV[0] == '!'
    is_refresh = true
    ARGV.shift
  end

  if !is_refresh and fb = alfred.feedback.get_cached_feedback
    # cached feedback is valid
    puts fb.to_alfred
  else
    fb = alfred.feedback

    fb = add_user_status_feedback(fb)
    fb = add_tasks_feedback(fb)
    # cache feedback
    fb.put_cached_feedback

    puts fb.to_xml(ARGV)
  end
end
