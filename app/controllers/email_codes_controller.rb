class EmailCodesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :verify]

  def new
  end

  def create
    email = params[:email].to_s.downcase

    if email.present?
      if !email.ends_with?("@utrgv.edu")
        flash[:alert] = "Only @utrgv.edu emails are allowed."
        redirect_to email_login_path
        return
      end
      user = User.find_or_create_by(email: email)
      code = SecureRandom.hex(3).upcase

      user.update(
        verification_code: code,
        code_sent_at: Time.current
      )

      UserMailer.verification_code_email(user).deliver_now
      redirect_to verify_code_path(email: email)
    else
      flash[:alert] = "Please enter a valid email."
      render :new
    end
  end

  def verify
    @user = User.find_by(email: params[:email])
  
    if @user&.disabled?
      flash[:alert] = "Your account has been disabled."
      redirect_to banned_path 
      return
    end
  
    if Rails.env.development? && params[:email] == "admin@utrgv.edu"
      @user ||= User.create!(email: params[:email], role: "admin", password: "adminpass")
      sign_in(@user)
      flash[:notice] = "Logged in as Admin (DEV bypass)"
      return redirect_to admin_dashboard_path
    end
  
    if request.post?
      if @user&.verify_code_matches?(params[:code])
        sign_in(@user)
        flash[:notice] = "Login successful!"
        redirect_to authenticated_root_path
      else
        flash.now[:alert] = "Invalid or expired verification code."
        render :verify, status: :unprocessable_entity
      end
    end
  end 
end 