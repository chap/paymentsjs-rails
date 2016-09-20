class PaymentsJs
	#require 'helpers/configuration'
	require 'openssl'
	require 'base64'
	require 'json'
  	require 'paymentsjs-rails/rails/engine'
	
	attr_reader :address, :city, :state, :zip, :amount, :req_id, :name, :request_type, :pre_auth, :environment, :api_key, :salt, :mid, :postback_url, :auth_key
	
	def initialize(order)
		
		p order
		
		@order        = order
		@address      = @order[:address]
		@city         = @order[:city]
		@state        = @order[:state]
		@zip          = @order[:zip]
		@amount       = @order[:total]
		@req_id       = @order[:req_id]
		@name         = @order[:name]
		@request_type = @order[:request_type]
		@pre_auth     = @order[:pre_auth]
		@environment  = @order[:environment]
		@mid          = @order[:mid]
		@mkey         = @order[:mkey]
		@api_key      = @order[:api_key]
		@api_secret   = @order[:api_secret]
		@postback_url = @order[:postback_url]
		
		cipher = OpenSSL::Cipher::AES.new(256, :CBC)
		cipher.encrypt

		iv = OpenSSL::Random.pseudo_bytes(16)
		salt = iv.unpack('H*').first
		salt = salt.bytes.to_a
		salt = salt.pack('U*')
		@salt = Base64.strict_encode64(salt)
		
		p @salt
		p @api_secret

		req  = {
			"apiKey"      => @api_key,
			"merchantId"  => @mid,
			"merchantKey" => @mkey,
			"requestType" => @request_type,
			"requestId"   => @req_id,
			"postbackUrl" => @postback_url,
			"amount"      => @amount,
			"nonce"       => @salt,
			"preAuth"     => @pre_auth,
			"environment" => @environment
		}

		data       = JSON.generate(req)
		key        = OpenSSL::PKCS5.pbkdf2_hmac_sha1(@api_secret, @salt, 1500, 32)
		cipher.key = key
		cipher.iv  = iv
		authKey    = cipher.update(data) + cipher.final()
		@auth_key   = Base64.strict_encode64(authKey)
		
	end
	
end