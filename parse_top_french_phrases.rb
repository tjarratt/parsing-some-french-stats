#!/usr/bin/env ruby
require 'json'

class TopFrenchItem
  attr_reader :rank, :word, :category, :translation, :exampleSentence

  def initialize(rank, word, category, translation, exampleSentence)
    @rank = rank.to_i
    @word = word
    @category = category
    @translation = translation
    @exampleSentence = exampleSentence
  end

  def to_json(*a)
    {
      :rank => @rank,
      :word => @word,
      :category => @category,
      :translation => @translation,
    }.to_json(*a)
  end
end

class ExampleSentence
  attr_reader :french, :english

  def initialize(french, english)
    @french = french
    @english = english
  end
end

def parse_next_top_french_item(input)
  # take line off the top
  line, remainder = read_next_line(input)
  return [nil, nil] unless line

  line_regexp = /^(\d+) ([[:alpha:]]+) ([[:alpha:]]+) (.+)$/
  matches = line.match(line_regexp)

  return [nil, remainder] unless matches

  rank = matches[1]
  word = matches[2]
  category = matches[3]
  english = matches[4]

  # validate category
  # newline
  # asterisk, french sentence (possible newline here)
  # double dash
  # english phrase (possible newline here)

  item = TopFrenchItem.new(rank, word, category, english, nil)

  return [item, remainder]
end

def read_next_line(input)
  return input[0], input[1..input.length - 1]
end

path = File.expand_path("~/Downloads/5000-french-words.txt")
lines = File.read(path)
  .split("\n")

items = []
while lines do
  item, next_lines = parse_next_top_french_item(lines)
  items << item if item
  lines = next_lines
end

puts "we read #{items.size} items out of the corpus"
puts "we are missing precisely #{(1.upto(5000).to_a - items.map(&:rank)).size} words"

file_handle = File.open('./out.js', 'w')
file_handle.write(items.to_json)
file_handle.close
