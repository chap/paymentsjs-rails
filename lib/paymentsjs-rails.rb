class PaymentsJs
	require 'helpers/configuration'
	require 'openssl'
	require 'base64'
	require 'json'
  	require 'paymentsjs-rails/rails/engine'
	
	extend Configuration
	
	cipher = OpenSSL::Cipher::AES.new(256, :CBC)
	cipher.encrypt

	iv = OpenSSL::Random.pseudo_bytes(16)
	salt = iv.unpack('H*').first
	salt = salt.bytes.to_a
	salt = salt.pack('U*')
	salt = Base64.strict_encode64(salt)
	
	req_id = "invoice" + rand(10...42).to_s

	define_setting :mid, "999999999997"
	define_setting :mkey, "K3QD6YWyhfD"
	define_setting :api_key, "7SMmEF02WyC7H5TSdG1KssOQlwOOCagb"
	define_setting :api_secret, "wtC5Ns0jbtiNA8sP"
	define_setting :req_id, req_id
	define_setting :request_type, "payment"
	define_setting :postback_url, "https://www.example.com"
	define_setting :amount, "1.00"
	define_setting :pre_auth, false
	define_setting :environment, "cert"
	
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
	
	req  = {
		"apiKey"      => api_key,
		"merchantId"  => mid,
		"merchantKey" => mkey,
		"requestType" => request_type,
		"requestId"   => req_id,
		"postbackUrl" => postback_url,
		"amount"      => amount,
		"nonce"       => salt,
		"preAuth"     => false,
		"environment" => environment
	}
	
	data       = JSON.generate(req)
	key        = OpenSSL::PKCS5.pbkdf2_hmac_sha1(api_secret, salt, 1500, 32)
	cipher.key = key
	cipher.iv  = iv
	authKey    = cipher.update(data) + cipher.final()
	authKey    = Base64.strict_encode64(authKey)
	
	define_setting :authKey, authKey
	define_setting :salt, salt
	
end