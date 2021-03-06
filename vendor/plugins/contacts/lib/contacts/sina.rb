require 'json'

class Contacts

  class Sina < Base
    attr_accessor :mycontacts
    URL         = "http://mail.sina.com.cn/"
    LOGIN_URL   = "http://mail.sina.com.cn/cgi-bin/login.cgi"
    
    def real_connect
      postdata = "logintype=uid&u=#{CGI.escape(@login)}&psw=#{CGI.escape(@password)}"

      data, resp, cookies, forward = my_Post(LOGIN_URL, postdata, "sina_free_mail_recid=false&sina_vip_mail_recid=false", "mail.sina.com.cn","x-www-form-urlencoded","GB2312")
      
      if !forward
        raise AuthenticationError, "用户名密码错误"
      end

      data, resp, cookies, forward = get(forward, cookies, LOGIN_URL) 
      
      data, resp, cookies, forward = get(forward, cookies, forward)
      p1 = resp.body.index('contacts:')
      p2 = resp.body.index('groups:', p1)
      contacts_str = resp.body[(p1+9)..(p2-5)]
      contacts_str.gsub!("&quot;", '"')
      @mycontacts = JSON.parse(contacts_str)
    end

    def contacts
      rlist = []
      contact_list = 	mycontacts["contact"]
      contact_list.each do |h|
        rlist << [h["name"], h["email"]]
      end
      rlist
    end

    private
def my_Post(url, postdata, cookies="", referer="",contenttype='xml',charset='UTF-8')
      url = URI.parse(url)
      http = open_http(url)
      resp, data = http.post("#{url.path}?#{url.query}", postdata,
                             "User-Agent" => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1) Gecko/20061010 Firefox/2.0",
                             "Accept-Encoding" => "gzip",
                             "Cookie" => cookies,
                             "Referer" => referer,
                             #"Content-Type" => 'application/x-www-form-urlencoded',
                             "Content-Type" => "application/#{contenttype}; charset=#{charset}"
                             )
      data = uncompress(resp, data)
      cookies = parse_cookies(resp.response['set-cookie'], cookies)
      forward = resp.response['Location']
      forward ||= (data =~ /<meta.*?url='([^']+)'/ ? CGI.unescapeHTML($1) : nil)
      if (not forward.nil?) && URI.parse(forward).host.nil?
        forward = url.scheme.to_s + "://" + url.host.to_s + forward
      end
      return data, resp, cookies, forward
    end
    
  end  
  
  TYPES[:sina] = Sina

end 
