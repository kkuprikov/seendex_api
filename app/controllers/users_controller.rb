class UsersController < ApplicationController
  # POST /users
  def create
    if user_params[:nickname].blank?
      render(json: { success: false,
                     errors: 'NICKNAME_EMPTY' }, status: 400) && return
    end

    begin
      @user = User.create!(user_params.merge(last_online_at: Time.now))
      render json: { success: true, payload: { id: @user.id } }, status: 200
    rescue ActiveRecord::RecordNotUnique
      render json: { success: false, errors: 'NICKNAME_TAKEN' }, status: 400
    end
  end

  # GET /users
  def index
    messages_count = Message.group('receiver_id').count # { user1_id: messages_count ... }
    users = User.all.as_json

    users_with_messages = []
    users_last_day = []
    others = []

    users.each do |u|
      if messages_count.keys.include? u['id']
        users_with_messages << u.merge(unread_messages: messages_count[u['id']])
        next
      end

      if u['last_online_at'] >= 1.day.ago.to_i
        users_last_day << u
        next
      end

      others << u
    end

    @users_sorted = order_by_last_online(users_with_messages) +
                    order_by_last_online(users_last_day) +
                    order_by_last_online(others)

    render json: { success: true, users: @users_sorted }, status: 200
  end

  private

  def user_params
    params.permit(:nickname)
  end

  def order_by_last_online(users)
    users.sort_by { |u| u['last_online_at'] }.reverse
  end
end
