# coding: utf-8
require 'sinatra'
require 'sinatra/streaming'
require 'erubis'

set server: 'thin', connections: [], syouhizei: "1.05"

Thread.new do
  loop do
    puts "connections: #{settings.connections.size.inspect}"
    settings.connections.each do |conn|
      data = "data: #{settings.syouhizei}\n\n"
      puts data
      conn << data
    end
    sleep 1
  end
end

get '/' do
  erb :index
end

get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |conn|
    settings.connections << conn
    conn.callback{settings.connections.delete(conn)}
    conn.errback{settings.connections.delete(conn)}
  end
end

get '/modify' do
  if params[:value] =~ /^[0-9\.]+$/
    settings.syouhizei = params[:value].to_f.to_s
  end
  settings.syouhizei
end

