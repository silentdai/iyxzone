module UsersHelper

  def email_login_url email
    # email肯定是合法的，不然不会在数据库里
    domain = email.split('@').last
    case domain
    when 'gmail.com' then "http://www.gmail.com"
    when 'yahoo.com.cn' then "http://mail.yahoo.com.cn"
    when 'yahoo.com' then "http://mail.yahoo.com"
    when 'hotmail.com' then "http://www.hotmail.com"
    when 'sina.com' then 'http://mail.sina.com'
    when 'sina.com.cn' then 'http://mail.sina.com.cn'
    when '163.com' then 'http://mail.163.com'
    when '263.com' then 'http://mail.263.com'
    when 'qq.com' then 'http://mail.qq.com'
    else
      # guess
      "http://#{domain}"
    end
  end

  def email_box email
    domain = email.split('@').last
    case domain
    when 'gmail.com' then "GMAIL"
    when 'yahoo.com.cn' then "雅虎"
    when 'yahoo.com' then "雅虎"
    when 'hotmail.com' then 'Hotmail'
    when 'sina.com.cn' then '新浪'
    when 'sina.com' then '新浪'
    when '163.com' then '163'
    when '263.com' then '263'
    when 'qq.com' then 'QQ'
    else
      # guess
      domain
    end
  end

end
