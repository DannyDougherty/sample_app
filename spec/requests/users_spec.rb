require 'spec_helper'

describe "Users" do

	describe "signup" do

		describe "failure" do
			
			before(:each) do
				
				visit signup_path
				fill_in "Name",			:with => ''
				fill_in "Email",		:with => ''
				fill_in "Password",		:with => ''
				fill_in "Confirmation",	:with => ''
				
			end
			
			it "should not add a new user" do
				
				lambda do
					click_button
				end.should_not change(User, :count)
				
			end
		
			it "should return to the signup page" do
				
				click_button
				response.should render_template('users/new')
				
			end
			
			it "should deliver errors to the user" do
				
				click_button
				response.should have_selector("div#error_explanation")
				
			end
		
		end
		
		describe "success" do
			
			before(:each) do
				visit signup_path
				fill_in "Name",			:with => "Example user"
				fill_in "Email",		:with => "User@Example.com"
				fill_in "Password",		:with => "foobar"
				fill_in "Confirmation",	:with => "foobar"
			end
			
			it "should add a user" do
				lambda do
					click_button
				end.should change(User, :count).by(1)
			end
			
			it "should go to the new user page" do
				click_button
				response.should render_template('users/show')
			end
			
			it "should greet the user" do
				click_button
				response.should have_selector("div.flash.success", :content => "Welcome")
			end
			
		end

	end
	
	describe "sign in/out" do
		
		describe "failure" do
			
			it "should not sign a user in" do
				visit signin_path
				fill_in :email, :with => ""
				fill_in :password, :with => ""
				click_button
				response.should have_selector("div.flash.error", :content => "Invalid")
			end
		end
		
		describe "success" do
			
			it "should have a user sign in and out" do
				integration_sign_in
				controller.should be_signed_in
				click_link "Sign out"
				controller.should_not be_signed_in
			end
			
		end
		
	end
  
end
