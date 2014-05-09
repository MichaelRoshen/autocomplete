#encoding: utf-8
class HomeController < ApplicationController
  def index
  	p params
  end

  def api
    search_words = get_user_search_words(:search_ws)
    p = PinYin.of_string(params[:q].strip).join("")
    #过滤出cookie从中与用户搜索词匹配的两个
    words = search_words.select{|x|x["p"] =~ /^#{p}/}.map{|y|y["q"]}.reverse[0..1] || []
    background = ["abc","adf","dfahbr","asdf","免费 App","s","sdfs"]
    #推荐词包括用户搜索的和后台匹配出来的
  	data = words + background
  	render :json => data.to_json
  end



  def search
  	set_user_search_words(:search_ws, params[:q].strip)
  	redirect_to :action => :index
  end
  
  private
  def set_user_search_words(key, q)
  	#binding.pry
    p = PinYin.of_string(q).join("")
  	if !cookies[key].present?
  		cookies[key] = [].to_json
  	end
  	search_words = JSON.parse(cookies[key])
  	if search_words.length < 10
      save_words_to_cookies(search_words, key, q, p)
  	elsif search_words.length == 10
      save_words_to_cookies(search_words, key, q, p) do |words|
        words.shift
      end
  	end
  end

  def save_words_to_cookies(words, key, q, p)
      tmp_h = {}
      tmp_h["q"] = q
      tmp_h["p"] = p
      yield words if block_given?
      words << tmp_h unless words.map{|word|word["q"]}.include?(q)
      cookies[key] = words.to_json  
  end

  def get_user_search_words(key)
    return [] if cookies[key].nil?
  	search_words = JSON.parse(cookies[key]) 
  end


end