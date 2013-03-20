require 'spec_helper'

describe UsersController do
	render_views
	
	describe "GET 'index'" do
		
		describe "for non-signed-in users" do
			
			it "should deny access" do
				get :index
				response.should redirect_to(signin_path)
				flash[:notice].should =~ /sign in/i
			end
			
		end
		
		describe "for signed-in users" do
			
			before(:each) do
				@user = test_sign_in(Factory(:user))
				second = Factory(:user, :email => "another@example.com")
				third = Factory(:user, :email => "another@example.net")
				
				@users = [@user, second, third]
				30.times do
					@users << Factory(:user, :email => Factory.next(:email))
				end
				get :index
			end
			
			it "should be sucessful" do
				response.should be_success
			end
			
			it "should have the right title" do
				response.should have_selector("title", :content => "All users")
			end
			
			it "should have an element for each user" do
				@users[0..2].each do |user|
					response.should have_selector('li', :content => user.name)
					#Shouldn't this check for <a> tags pointing to user pages instead to eliminate a hard tie to lists?
				end
			end
			
			it "should paginate users" do
				response.should have_selector("div.pagination")
				response.should have_selector("span.disabled", :content => "Previous")
				response.should have_selector("a", :href => "/users?page=2", :content => "2")
				response.should have_selector("a", :href => "/users?page=2", :content => "Next")
			end
			
			describe "(non-admin users)" do
				it "should not show delete links" do
					response.should_not have_selector("a", :content => "delete")
				end
			end
			
			describe "(admin users)" do
				it "should show delete linkes" do
					@user.toggle!(:admin)
					get :index
					response.should have_selector("a", :content => "delete")
				end
			end
			
		end
		
	end
	
	describe "GET 'show'" do
		before(:each) do
			@user = Factory(:user)
		end
		
		it "should be succesful" do
			get :show, :id => @user #Rails will call the to_aparam method here to automatically get @user.id
			response.should be_success
		end
		
		it "should find the right user" do
			get :show, :id => @user
			assigns(:user).should == @user
		end
		
		it "should have the right title" do
			get :show, :id => @user
			response.should have_selector("title", :content => @user.name)
		end
		
		it "should include the user's name" do
			get :show, :id => @user
			response.should have_selector("h1", :content => @user.name)
		end
		
		it "should have a profile image" do
			get :show, :id => @user
			response.should have_selector("h1>img", :class => "gravatar")
		end
	end
	
	describe "GET 'new'" do
	
		before(:each) do
			get :new
		end
		
		it "should be successful" do
		  response.should be_success
		end
		
		it "should have the right title" do
			response.should have_selector('title', :content => "Ruby on Rails Tutorial Sample App | Sign up")
		end
		
		it "should have a name field" do
			response.should have_selector("input[name='user[name]'][type='text']")
		end
		
		it "should have an email field" do
			response.should have_selector("input[name='user[email]'][type='text']")
		end
		
		it "should have a password field" do
			response.should have_selector("input[name='user[password]'][type='password']")
		end
		
		it "should have a confirmation for the password" do
			response.should have_selector("input[name='user[password_confirmation]'][type='password']")
		end
	end
	
	describe "POST create" do
		describe "failure" do
			before(:each) do
				@attr = { :name => "", :email => "", :password => "", :password_confirmation => "" }
			end
			
			it "should create a user" do
				lambda do
					post :create, :user => @attr
				end.should_not change(User, :count)
			end
		end
		
		describe "success" do
			before(:each) do
				@attr = { :name => "New User", :email => "user@example.com", :password => "foobar", :password_confirmation => "foobar" }
			end
			
			it "should create a user" do
				lambda do
					post :create, :user => @attr
				end.should change(User, :count).by(1)
			end
			
			it "should have a welcome message" do
				post :create, :user => @attr
				flash[:success].should =~ /welcome to the sample app/i
			end
			
			it "should sign the user in" do
				post :create, :user => @attr
				controller.should be_signed_in
			end
		end
	end
	
	describe "DELETE 'destroy'" do
		
		before(:each) do
			@user = Factory(:user)
		end
		
		describe "as a non-signed-in user" do
			it "should not destroy the user" do
				lambda do
					delete :destroy, :id => @user
				end.should_not change(User, :count)
			end
			
			it "should deny access" do
				delete :destroy, :id => @user
				response.should redirect_to(signin_path)
			end
		end
		
		describe "as a non-admin user" do
			it "should not destroy the user" do
				lambda do
					delete :destroy, :id => @user
				end.should_not change(User, :count)
			end
			
			it "should protect the page" do
				test_sign_in(@user)
				delete :destroy, :id => @user
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an admin user" do
			
			before(:each) do
				@admin = Factory(:user, :email => "admin@example.com", :admin => true)
				test_sign_in(@admin)
			end
			
			it "should destroy the user" do
				lambda do
					delete :destroy, :id => @user
				end.should change(User, :count).by(-1)
			end
			
			it "should not let admin users delete themselves" do
				lambda do
					delete :destroy, :id => @admin
				end.should_not change(User, :count).by(-1)
			end
			
			it "should redirect to the users page" do
				delete :destroy, :id => @user
				response.should redirect_to(users_path)
			end
			
		end
		
	end
	
	describe "GET 'edit'" do
		
		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
			get :edit, :id => @user
		end
		
		it "should be succesful" do
			response.should be_success
		end
		
		it "should have the right title" do
			response.should have_selector("title", :content => "Edit user")
		end
		
		it "should have a link to change the gravatar" do
			gravatar_url = "http://gravatar.com/emails"
			response.should have_selector("a", :href => gravatar_url)
		end
		
	end
	
	describe "PUT 'update'" do
		
		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
		end
		
		describe "failure" do
			
			before(:each) do
				@attr = {:email => '', :name => '', :password => '', :password_confirmation => ''}
				put :update, :id => @user, :user => @attr
			end
			
			it "should render the 'edit' page" do
				response.should render_template('edit')
			end
			
			it "should have the right title" do
				response.should have_selector("title", :content => "Edit user")
			end
			
		end
		
		describe "success" do
			
			before(:each) do
				@attr = {:email => 'user@example.org', :name => 'New name', :password => 'barbar', :password_confirmation => 'barbar'}
				put :update, :id => @user, :user => @attr
			end
			
			it "should change the user's attributes" do
				@user.reload
				@user.name.should == @attr[:name]
				@user.email.should == @attr[:email]
			end
			
			it "should redirect to the user show page" do
				response.should redirect_to(user_path(@user))
			end
			
			it "should have a flash mesaage" do
				flash[:success].should =~ /updated/
			end
			
		end
		
	end
	
	describe "authentication of edit/update pages" do
		
		before(:each) do
			@user = Factory(:user)
		end
		
		describe "for non-signed in users" do
			
			it "should deny access to 'edit' page" do
				get :edit, :id => @user
				response.should redirect_to(signin_path)
			end
			
			it "should deny access to 'update'" do
				put :update, :id => @user, :user => ()
				response.should redirect_to(signin_path)
			end
			
		end
		
		describe "for signed in users" do
			
			before(:each) do
				wrong_user = Factory(:user, :email => "user@example.net")
				test_sign_in(wrong_user)
			end
			
			it "should require matching users for 'edit'" do
				get :edit, :id => @user
				response.should redirect_to(root_path)
			end
			
			it "should require matching users for 'update'" do
				put :update, :id => @user, :user => ()
				response.should redirect_to(root_path)
			end
			
		end
		
	end
end
