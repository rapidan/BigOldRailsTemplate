class ActivationsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]

  def new
    @user = User.find_using_perishable_token(params[:activation_code], 1.week)
    raise Exception unless @user && !@user.active?
    @page_title = "Activate Your Account"
  end

# TODO: Reset token and resend email on expired token

  def create
    @user = User.find(params[:id])

    if !@user || @user.active?
      redirect_to root_url and return
    end

    if @user.activate!(params)
      @user.deliver_welcome_email!
      flash[:notice] = "Your account has been activated."
      redirect_to root_url
    else
      render :action => :new
    end
  end

end
