class IndexController < ApplicationController

	@@gateway = "https://www.alipay.com/cooperate/gateway.do?"        #支付接口
	@@parameter = ""
	#
	@@security_code = ""
	#
	@@mysign  = ""         #签名
	#
  #功能：设置商品有关信息
	#版本：2.0
	#日期：2008-08-01
	#作者：支付宝公司销售部技术支持团队
	#联系：0571-26888888
	#版权：支付宝公司
  def index
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
    @show_url       = "http://"        #你网站商品的展示地址       
    # 
    @parameter = {
    	"service"         => "create_direct_pay_by_user",  #交易类型
    	"partner"         => @partner,          #合作商户号
    	"return_url"      => @return_url,       #同步返回
    	"notify_url"      => @notify_url,       #异步返回
    	"_input_charset"  => @_input_charset,   #字符集，默认为GBK
    	"subject"         => "商品名称",        #商品名称，必填
    	"body"            => "商品描述",        #商品描述，必填
    	"out_trade_no"    => DateTime.now.strftime('%Y%m%d%H%M%S'),      #商品外部交易号，必填（保证唯一性）
    	"payment_type"    => "1",               #默认为1,不需要修改
    	"total_fee"       => "0.01",  #商品单价，必填（价格不能为0）
    	"show_url"        => @show_url,         #商品相关网站
    	"seller_email"    => @seller_email      #卖家邮箱，必填
    }
    alipay_service(@parameter,@security_code,@sign_type,"https")
    @link = create_url()
    #redirect_to @link
  end  

  protected
	
  def alipay_service(parameter,security_code,sign_type,transport) 
		@@parameter  = para_filter(parameter)
		@@security_code  = security_code
		@@sign_type      = sign_type
		@@mysign         = ''
		@@transport      = transport
		if(parameter['_input_charset'] == "")
		  @@parameter['_input_charset']='GBK'
	  end
		if(@@transport == "https") 
		  @@gateway = "https://www.alipay.com/cooperate/gateway.do?"
		else 
		  @@gateway = "http://www.alipay.com/cooperate/gateway.do?"
	  end
		sort_array = {}
		arg = ""
		sort_array = @@parameter
		sort_array.keys.sort.each do |key|
		  arg+=key+"="+sort_array[key]+"&"
	  end
	  prestr = arg[0,arg.length-1]
	  @@mysign = sign(prestr+@@security_code)
	end	
		
	def create_url() 
		url        = @@gateway
		sort_array = {}
		arg        = ""
		sort_array = @@parameter
		sort_array.keys.sort.each do |key|
		  arg+=key+"="+URI.escape(sort_array[key])+"&"
	  end
	  url+=arg+"sign="+@@mysign+"&sign_type="+@@sign_type
	  return url
  end
		
	def sign(prestr) 
		mysign = ""
		if(@@sign_type == 'MD5') 
			mysign = Digest::MD5.hexdigest(prestr)
		elsif (@@sign_type =='DSA') 
			#DSA 签名方法待后续开发
			exit("DSA 签名方法待后续开发，请先使用MD5签名方式")
		else 
			exit("支付宝暂不支持"+@@sign_type+"类型的签名方式")
		end
		return mysign
	end
	
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
