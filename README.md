# Sage PaymentsJS-Rails Gem

####NOTE: This gem is not yet finished and has not been extensively tested, be very careful using this gem until v.1.0 is released.

The PaymentsJS-Rails gem simplifies the integration of Sage's PaymentsJS SDK by adding the PaymentsJs model and making configuring environmental variables easy.

##Installation
Add it to your Gemfile:
```bash
gem 'paymentsjs-rails'
```
	
Use Bundler to install:
```bash	
bundle install
```
	
And add the following file:
```ruby
config/initializers/paymentsjs-rails.rb
```	
Then, in your `app/assets/javascripts/application.js` file, add:
```javascript
//= require pay //this adds the pay.min.js file provided via Sage CDN
```
	
Currently this gem is only intended for those using the PayJS(['PayJS/UI']) module. With time it will be extended to other modules. 

##Quick Start

Follow the [PaymentsJS GitHub Quick Start guide](https://github.com/SagePayments/PaymentsJS "PaymentsJS"), minus the 
```html
<script type="text/javascript" src="https://www.sagepayments.net/pay/1.0.0/js/pay.min.js"></script>
```
part.

PaymentsJS requires several variables to be added to the `$UI.Initialize()` function in order to work. The Quick Start comes with several variables preloaded. We'll replace these with embedded ruby to call the same preloaded variables:

```javascript
PayJS(['PayJS/UI'], // the name of the module we want to use
function($UI) { // assigning the module to a variable
	$UI.Initialize({ // configuring the UI
		apiKey: "<%= PaymentsJs.api_key %>", // your developer ID
		merchantId: "<%= PaymentsJs.mid %>", // your 12-digit account identifier
		authKey: "<%= PaymentsJs.encrypt %>", // covered in the next section!
		requestType: "<%= PaymentsJs.request_type %>", // use can use "vault" to tokenize a card without charging it
		requestId: "<%= PaymentsJs.req_id %>", // an order number, customer or account identifier, etc.
		amount: "<%= PaymentsJs.amount %>", // the amount to charge the card. in test mode, different amounts produce different results.
		elementId: "paymentButton", // the page element that will trigger the UI
		nonce: "<%= PaymentsJs.salt %>", // a unique identifier, used as salt
		debug: true, // enables verbose console logging
		preAuth: <%= PaymentsJs.pre_auth %>, // run a Sale, rather than a PreAuth
		environment: "<%= PaymentsJs.environment %>", // hit the certification environment
		addFakeData: true,
		billing: {
			name: "Shaka Smart",
			address: "",
			City: "Denver",
			state: "CO",
			postalCode: "80205"
		}
	});
	$UI.setCallback(function(result) { // custom code that will execute when the UI receives a response
		console.log(result.getResponse()); // log the result to the console
		var wasApproved = result.getTransactionSuccess();
		alert(wasApproved ? "ka-ching!" : "bummer");
	});
});
```

Reload the page and the payment system should work.

##Configuring

In your `config/initializers/paymentsjs-rails.rb` file, add this:
```ruby
PaymentsJs.configuration do |config|
	config.mid          = "YOUR MERCHANT ID"
	config.mkey         = "YOUR MERCHANT KEY"
	config.api_key      = "YOUR API KEY"
	config.api_secret   = "YOUR SECRET KEY"
	config.postback_url = "YOUR POSTBACK URL"
end
```
This will override the default variables.

##Integration

Integrating is easy and very variable. There are several values that will need to be dynamically set, and in a semi-order. Before you can call `PaymentsJs.encrypt` the following variables need to be set:
```ruby
PaymentsJs.amount       = "ORDER PRICE" #note, this needs to be a string, not a float/integer
PaymentsJs.req_id       = "ORDER NUMBER" #if blank, "invoice(xx)" with xx being a random integer between 10 and 42 will be generated
PaymentsJs.request_type = "ORDER REQUEST TYPE"
PaymentsJs.pre_auth     = boolean
PaymentsJs.environment  = "ORDER ENVIRONMENT"
```
The other variables are generated by encryption. 
