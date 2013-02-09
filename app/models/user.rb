# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
	attr_accessor :password
	attr_accessible :email, :name, :password, :password_confirmation
	
	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	
	validates :name,	:presence => true,
						:length => { :maximum => 50 }
	
	validates :email,	:presence => true,
						:format => { :with => email_regex },
						:uniqueness => { :case_sensitive => false }
	
	# automatically create the virtual attribute password_confirmation
	validates :password,	:presence => true,
							:confirmation => true,
							:length => { :within => 6...40 }
	
	before_save :encrypt_password
	
	private
	
		def encrypt_password
			self.encrypted_password = encrypt(password)
		end
		
		def encrypt(string)
			string #placeholder for later encryption function
		end
	
end
