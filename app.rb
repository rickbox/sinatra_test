require "bundler/setup"
require "sinatra"
require "sinatra/reloader"


Json_file_path = "data/data.json"


#jsonをハッシュに
$memos_hash = open(Json_file_path) do |file|
  JSON.load(file)
end

#ハッシュから配列に
memos_array = $memos_hash["memos"]


get "/" do
  @memos = memos_array
  erb :index
end

get "/create" do
  erb :create
end

post "/new" do
  new_id = memos_array.last["id"] + 1
  new_memo = {"id" => new_id, "title" => params[:title], "content" => params[:content]}
  $memos_hash["memos"].push(new_memo)

  update_data
  redirect "/"
end

get "/show/:id" do |id|
  @memo = $memos_hash["memos"].select {|memo| memo["id"] == id.to_i }
  erb :show
end

delete "/destroy/:id" do |id|
  $memos_hash["memos"].delete_if {|memo| memo["id"] == id.to_i }

  update_data
  redirect "/"
end

get "/edit/:id" do |id|
  @memo = $memos_hash["memos"].select {|memo| memo["id"] == id.to_i }
  erb :edit
end

patch '/update/:id' do |id|
  #配列のインデックス取得
  index = $memos_hash["memos"].find_index {|memo| memo["id"] == id.to_i }
  $memos_hash["memos"][index] = {"id" => id.to_i, "title" => params[:title], "content" => params[:content]}

  update_data
  redirect "/show/#{id}"
end

#jsonの更新
def update_data
  File.open(Json_file_path, "w") do |file|
    JSON.dump($memos_hash, file)
  end
end