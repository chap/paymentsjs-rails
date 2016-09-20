class PaymentsJs
	require 'helpers/configuration'
	require 'openssl'
	require 'base64'
	require 'json'
  	require 'paymentsjs-rails/rails/engine'
	
	extend Configuration
	
	def self.generate_req_id
		req_id = "invoice" + rand(10...42).to_s
		req_id
	end
	
	def self.generate_iv
		iv = OpenSSL::Random.pseudo_bytes(16)
		iv
	end
	
	def self.generate_salt
		salt = PaymentsJs.iv.unpack('H*').first
		salt = salt.bytes.to_a
		salt = salt.pack('U*')
		salt = Base64.strict_encode64(salt)
		salt
	end

	define_setting :mid, "999999999997"
	define_setting :mkey, "K3QD6YWyhfD"
	define_setting :api_key, "7SMmEF02WyC7H5TSdG1KssOQlwOOCagb"
	define_setting :api_secret, "wtC5Ns0jbtiNA8sP"
	define_setting :req_id, PaymentsJs.generate_req_id
	define_setting :request_type, "payment"
	define_setting :postback_url, "https://www.example.com"
	define_setting :amount, "1.00"
	define_setting :pre_auth, false
	define_setting :environment, "cert"
	define_setting :iv, PaymentsJs.generate_iv
	define_setting :salt, PaymentsJs.generate_salt
	
	def self.req
		mid          = PaymentsJs.mid
		mkey         = PaymentsJs.mkey
		api_key      = PaymentsJs.api_key
		api_secret   = PaymentsJs.api_secret
		req_id       = PaymentsJs.req_id
		request_type = PaymentsJs.request_type
		postback_url = PaymentsJs.postback_url
		amount       = PaymentsJs.amount
		pre_auth     = PaymentsJs.pre_auth
		environment  = PaymentsJs.environment
		
		req = {mid: mid, mkey: mkey, api_key: api_key, api_secret: api_secret, req_id: req_id, request_type: request_type, postback_url: postback_url, amount: amount, pre_auth: pre_auth, environment: environment }
		
		req
	end
	
	def self.encrypt
		cipher     = OpenSSL::Cipher::AES.new(256, :CBC)
		cipher.encrypt
		req        = PaymentsJs.req
		api_secret = PaymentsJs.api_secret
		data       = JSON.generate(req)
		salt       = PaymentsJs.salt
		key        = OpenSSL::PKCS5.pbkdf2_hmac_sha1(api_secret, salt, 1500, 32)
		cipher.key = key
		cipher.iv  = PaymentsJs.iv
		authKey    = cipher.update(data) + cipher.final()
		authKey    = Base64.strict_encode64(authKey)
		authKey
	end
	
end