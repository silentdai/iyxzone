class Youku
	
	# http://v.youku.com/v_show/id_XMTUzMzE4OTAw.html	
	# 
	YOUKU_SINGLE	= /http:\/\/v\.youku\.com\/v_show\/id_[\w]*\=?\.htm[l]?/
	# http://v.youku.com/v_playlist/f3921377o1p0.html 
	# <embed src="http://player.youku.com/player.php/Type/Folder/Fid/3921377/Ob/1/Pt/0/sid/XMTQyNzQ3MzY=/v.swf" quality="high" width="480" height="400" align="middle" allowScriptAccess="allways" mode="transparent" type="application/x-shockwave-flash"></embed>
	YOUKU_ALBUM		= /http:\/\/v\.youku\.com\/v_playlist\/[\w]*\.htm[l]?/

	include HTTParty

	format :json

	base_uri 'v.youku.com/player/getPlayList'

	def self.identify_url(videourl)
		puts YOUKU_SINGLE
		if YOUKU_SINGLE.match(videourl)
			return true
		end
	end

	
	def initialize(obj)
		@video_id = obj.video_url.split('id_').last.split('.').first
		@embed_url = "http://player.youku.com/player.php/sid/"+ @video_id +"/v.swf"
		@response  = self.class.get("/VideoIDS/#{@video_id}")
	end

	def thumbnail_url
		if @response
			@response["data"][0]["logo"] 
		else
			"/images/videoThumb/youku.png"
		end
	end

	def embed_html
		"<param name=\"wmode\" value=\"transparent\"/><embed src=\""+ @embed_url + "\" quality=\"high\" width=\"470\" height=\"392\" align=\"middle\" allowScriptAccess=\"sameDomain\" type=\"application/x-shockwave-flash\" wmode=\"transparent\"></embed>"
	end

end
