class SessionsController < ApplicationController

before_action :require_user, only: [:destroy]
  def new

    
  end

  def create
    # ex user.authenticate('password')
    # 1. get the user obj
    # 2. see if passowrd matches
    # 3. if so, log in
    # 4. if no, redirect

    user = User.where(username: params[:username]).first
    # where gives and array, even if only one. That's why add .first at the end

    if user && user.authenticate(params[:password])
      if user.two_factor_auth?
        session[:two_factor] = true
        # gen a pin
        user.generate_pin!
        user.send_pin_to_twilio
        # send pin to twilio, sms to user's phone
        redirect_to pin_path
        # show pin form
      else
        login_user!(user)
      end
    else
        flash[:error] = "There's something wrong with username or password"
        render :new
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "You've logged out."
    redirect_to root_path
  end

  def pin
    access_denied if session[:two_factor].nil?
    if request.post?
      user = User.find_by pin: params[:pin]
      if user
        session[:two_factor] = nil
        user.remove_pin!
        login_user!(user)
      else
        flash[:error] = "Sorry, something is wron with your pin number"
        redirect_to pin_path
      end
    end
  end

  private
    def login_user!(user)
      session[:user_id] = user.id
      flash[:notice] = "Welcome, you've logged in."
      redirect_to root_path
    end

end
