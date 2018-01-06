#!/usr/bin/env ruby

# fetch local path to folder containing mastino repo, return as json object with key "path"
require 'json'
puts JSON.generate(path: File.expand_path("../../../../../", __FILE__))
