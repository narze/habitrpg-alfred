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
  file = File.new("user.txt", "r")
  api_user = file.gets.chomp
  api_key = file.gets.chomp

  uri = URI.parse("https://habitrpg.com:443/api/v2/user/#{ARGV.join}")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  req = Net::HTTP::Post.new(uri.path)
  req['x-api-user'] = api_user
  req['x-api-key'] = api_key
  res = https.request(req)
  status = JSON.parse(res.body)
  hp = status["hp"]
  lvl = status["lvl"]
  exp = status["exp"]
  gp = status["gp"]

  puts "HP:#{hp.round} LV:#{lvl} EXP:#{exp.round} GP:#{gp.round}"
end

