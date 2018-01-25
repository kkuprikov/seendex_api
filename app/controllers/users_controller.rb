class UsersController < ApplicationController

  # POST /users
  def create
    if user_params[:nickname].blank?
      render json: { success: false, 
                     errors: 'NICKNAME_EMPTY'}, status: 400 and return
    end
    
    begin
      @user = User.create!(user_params.merge(last_online_at: Time.now))
      render json: { success: true, payload: { id: @user.id } }, status: 200
    rescue ActiveRecord::RecordNotUnique
      render json: { success: false, errors: 'NICKNAME_TAKEN'}, status: 400      
    end
  end

  private

  def user_params
    params.permit(:nickname)
  end

end
