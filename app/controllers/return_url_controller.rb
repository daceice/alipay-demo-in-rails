class ReturnUrlController < ApplicationController  
	@@gateway = ""       #支付接口
	@@security_code = ""	#安全校验码
	@@partner = PARTNER    #合作伙伴ID
	@@sign_type = ""       #加密方式 系统默认
	@@mysign = ""       #签名     
	@@_input_charset = ""    #字符编码格式
	@@transport = ""        #访问模式
	
	
  def return_url
    @partner        = PARTNER       #合作伙伴ID
    @security_code  = KEY       #安全检验码
    @seller_email   = SELLEREMAIL       #卖家支付宝帐户
    @_input_charset = "utf-8"  #字符编码格式  目前支持 GBK 或 utf-8
    @sign_type      = "MD5"    #加密方式  系统默认(不要修改)
    @transport      = "https"  #访问模式,你可以根据自己的服务器是否支持ssl访问而选择http以及https访问模式(系统默认,不要修改)
    #
    @notify_url     = NOTIFYURL #交易过程中服务器通知的页面 要用 http://格式的完整路径
    #
    @return_url     = CALLBACKURL #付完款后跳转的页面 要用 http://格式的完整路径
    #
    @show_url       = "http://www.veryrender.com"        #你网站商品的展示地址       

    alipay_notify(@partner,@security_code,@sign_type,@_input_charset,@transport)
    verify_result = return_verify()

    #获取支付宝的反馈参数
    out_trade_no = params['out_trade_no']  #获取订单号
    total_fee = params['total_fee']     #获取总价格
#    receive_name    =params['receive_name']   #获取收货人姓名
#    receive_address =params['receive_address']#获取收货人地址
#    receive_zip     =params['receive_zip']   #获取收货人邮编
#    receive_phone   =params['receive_phone']  #获取收货人电话
#    receive_mobile  =params['receive_mobile'] #获取收货人手机

    if(verify_result)     #认证合格
      @result = "success"
      #这里放入你自定义代码,比如根据不同的trade_status进行不同操作
      #log_result("verify_success")
    else     #认证不合格
      @result = "fail"
      #log_result ("verify_failed")
    end    
  end  
  
  protected 
  
  
  #  日志消息,把支付宝反馈的参数记录下来
  def log_result(word)
# 	fp = fopen("log.txt","a")
#  	flock(fp, LOCK_EX) 
#  	fwrite(fp,word."：执行日期："+strftime("%Y%m%d%H%I%S",time())+"\t\n")
#  	flock(fp, LOCK_UN);
#  	fclose(fp)
  end
  
  
 	def alipay_notify(partner,security_code,sign_type,$_input_charset,$transport) 
 		@@partner        = partner
 		@@security_code  = security_code
 		@@sign_type      = sign_type
 		@@mysign         = ""
 		@@_input_charset = _input_charset 
 		@@transport      = transport
 		if(@@transport == "https") 
 			@@gateway = "https://www.alipay.com/cooperate/gateway.do?"
 		else 
 		  @@gateway = "http://notify.alipay.com/trade/notify_query.do?"
	  end
  end
	  
  #################对notify_url的认证#################
	def notify_verify()
		if(@@transport == "https")
			veryfy_url = @@gateway+"service=notify_verify"+"&partner="+@@partner+"&notify_id="+params["notify_id"]
		else
			veryfy_url = @@gateway+"partner="+@@partner+"&notify_id="+params["notify_id"]
		end
		veryfy_result  = get_verify(veryfy_url)
		post           = para_filter(params)
		sort_post      = post
		arg = ""
		sort_post.keys.sort.each do |key|
		  arg+=key+"="+sort_post[key]+"&"
	  end
  	prestr = arg[0,arg.length-1]
	  @@mysign = sign(prestr+@@security_code)
	  #log_result("notify_url_log:sign=".$_POST["sign"]."&mysign=".$this->mysign."&".$this->charset_decode(implode(",",$_POST),$this->_input_charset ));
		if (with_true("true$",veryfy_result) && @@mysign == params["sign"])  
			return true
		else
		  return false
	  end
	end
  	
	def with_true(sub,obj)  
    check=(obj=~/#{sub}/)
    if check==nil || obj.to_i==0
      return false
    else
      return true
    end
  end
     
  ##################对return_url的认证####################
	def return_verify() 
		sort_get= params
		arg=""
		sort_get.keys.sort.each do |key|
			if (key != "sign" && key != "sign_type" )
				arg+=key+"="+ sort_get[key]+"&"
			end
		end
		prestr = arg[0,arg.length-1]  #去掉最后一个&号
		@@mysign = sign(prestr+@@security_code);
	#	log_result("return_url_log="+params["sign"]+"&"+@@mysign+"&"+implode(",",params))
		if (@@mysign == params["sign"])  
		  return true
		else 
		  return false
	  end
  end
  
	def get_verify(url, time_out = "60") 
	 	urlarr     = parse_url(url)
		errno      = ""
		errstr     = ""
		transports = ""
		if(urlarr["scheme"] == "https") 
			transports = "ssl://"
			urlarr["port"] = "443"
		else
			transports = "tcp://"
			urlarr["port"] = "80"
		end
=begin
		fp=@fsockopen(transports+urlarr['host'],urlarr['port'],errno,errstr,time_out);
		if(!fp) 
			exit("ERROR: $errno - $errstr<br />\n")
		else 
			fputs(fp, "POST "+urlarr["path"]+" HTTP/1.1\r\n")
			fputs(fp, "Host: "+$urlarr["host"]+"\r\n")
			fputs(fp, "Content-type: application/x-www-form-urlencoded\r\n")
			fputs(fp, "Content-length: "+strlen(urlarr["query"])+"\r\n")
			fputs(fp, "Connection: close\r\n\r\n")
			fputs(fp, $urlarr["query"]+"\r\n\r\n")
			while(!feof($fp)) {
				$info[]=@fgets($fp, 1024);
			}
  			fclose($fp);
			$info = implode(",",$info);
=end
      arg=""
			params.keys.each do |key|
			  arg+=key+"="+params[key]+"&"
		  end
	#		log_result("notify_url_log="+url+info)
	#		log_result("notify_url_log="+arg)
			return info
		end
	end
	
	def sign(prestr) 
		sign=''
		if(@@sign_type == 'MD5') 
			sign = Digest::MD5.hexdigest(prestr)
		elsif(@@sign_type =='DSA') 
			#DSA 签名方法待后续开发
			exit("DSA 签名方法待后续开发，请先使用MD5签名方式")
		else 
			exit("支付宝暂不支持"+@@sign_type+"类型的签名方式")
		end
		return sign
	}

  #############除去数组中的空值和签名模式#################
  def para_filter(parameter)  #除去数组中的空值和签名模式
		para = {}
		parameter.keys.each do |key|
			if !(key == "sign" || key == "sign_type" || parameter[key] == "")
				para[key] = parameter[key]
			end
		end
		return para
	end
end
