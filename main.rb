#!/usr/bin/env ruby
=begin 

Это скрипт резервного копирования всех объектов с cloudstorage на локальный компьютер.
Для использования скрипта необходим установленный gem - cloudfiles, optparse, fileutils


Запуск скрипта проиходит передачей 3-х параметров, которые содержат в себе:
 - Api пользователя
 - Api ключ
 - Ссылку на api

=end

require 'cloudfiles'
require 'fileutils'
require 'optparse'
require 'logger'

pwd = Dir.getwd
time = Time.new()
time = time.strftime("%Y-%m-%d-%H:%M:%S")

options = {}

logger = Logger.new('cloudbackup.log', 'daily')

OptionParser.new do |opts|
    opts.banner = "Usage: main.rb [options]"

    options[:verbose] = false

    opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = true
    end

    opts.on("-o", "--api-host [HOST]","Api url") do |api_url|
        options[:url] = api_url
    end

    opts.on("-u", "--api-user [USER]","Api user") do |api_user|
        options[:user] = api_user
    end

    opts.on("-k", "--api-key [KEY]", "Api cloud key") do |api_key|
        options[:key] = api_key
    end

end.parse!

p "#{options}" if options[:verbose] == true

p ARGV if options[:verbose] == true

p "#{options[:user]} - #{options[:key]} - #{options[:url]}" if options[:verbose] == true

cf = CloudFiles::Connection.new(:username => "#{options[:user]}", :api_key => "#{options[:key]}", :auth_url => "#{options[:url]}")

cf.containers if options[:verbose] == true

puts cf.containers if options[:verbose] == true

container = cf.container('public')

container.objects.each do |objects|
	obj_dirname = File.dirname("#{objects}")
	obj_basename = File.basename("#{objects}")

	if File.exist?("#{pwd}/#{obj_dirname}") == false
		FileUtils.mkdir_p "#{pwd}/#{obj_dirname}"
		puts "FileUtils.mkdir_p \"#{pwd}/#{obj_dirname}\"" if options[:verbose] == true
        logger.info("Create directory #{pwd}/#{obj_dirname}") if options[:verbose] == false
	end
	
	if File.exist?("#{pwd}/#{obj_dirname}") == true && File.exist?("#{pwd}/#{obj_dirname}/#{obj_basename}") == false
        `wget -q http://static.metrika.ru/public/#{objects} -O #{pwd}/#{obj_dirname}/#{obj_basename}`
        puts "wget http://static.metrika.ru/public/#{objects} -O #{pwd}/#{obj_dirname}/#{obj_basename}" if options[:verbose] == true
        logger.info("Backup #{obj_basename}") if options[:verbose] == false
	end
end

logger.close