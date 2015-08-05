class SessionsController < ApplicationController

before_action :require_user, except:[:new, :create]
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
        # gen a pin
        user.generate_pin!
        # send pin to twilio, sms to user's phone
        redirect_to pin_path
        # show pin form
      else
        session[:user_id] = user.id
        flash[:notice] = "You've logged in."
        redirect_to root_path
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

end
