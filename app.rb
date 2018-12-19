# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'

JSON_FILE_PATH = 'data/data.json'

def load_json
  open(JSON_FILE_PATH) do |file|
    JSON.load(file)
  end
end

get '/' do
  memos_hash = load_json
  @memos = memos_hash['memos']
  erb :index
end

get '/create' do
  erb :create
end

post '/new' do
  memos_hash = load_json
  new_id = memos_hash['memos'].last['id'] + 1
  new_memo = { 'id' => new_id, 'title' => params[:title], 'content' => params[:content] }
  memos_hash['memos'].push(new_memo)

  File.open(JSON_FILE_PATH, 'w') do |file|
    JSON.dump(memos_hash, file)
  end
  redirect '/'
end

get '/:id' do |id|
  memos_hash = load_json
  @memo = memos_hash['memos'].select { |memo| memo['id'] == id.to_i }
  erb :show
end

delete '/:id' do |id|
  memos_hash = load_json
  memos_hash['memos'].delete_if { |memo| memo['id'] == id.to_i }

  File.open(JSON_FILE_PATH, 'w') do |file|
    JSON.dump(memos_hash, file)
  end
  redirect '/'
end

get '/edit/:id' do |id|
  memos_hash = load_json
  @memo = memos_hash['memos'].select { |memo| memo['id'] == id.to_i }
  erb :edit
end

patch '/update/:id' do |id|
  memos_hash = load_json
  # 配列のインデックス取得
  index = memos_hash['memos'].find_index { |memo| memo['id'] == id.to_i }
  memos_hash['memos'][index] = { 'id' => id.to_i, 'title' => params[:title], 'content' => params[:content] }

  File.open(JSON_FILE_PATH, 'w') do |file|
    JSON.dump(memos_hash, file)
  end
  redirect "/#{id}"
end
