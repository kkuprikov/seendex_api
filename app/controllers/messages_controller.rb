class MessagesController < ApplicationController


  def create
    if message_params[:from].blank? || message_params[:to].blank?
      render json: { success: false, 
                     errors: 'USER_NOT_FOUND' }, status: 400 and return
    end


    @sender = User.find_by_id message_params[:from]
    @receiver = User.find_by_id message_params[:to]

    if @sender.nil? || @receiver.nil?
      render json: { success: false, 
                     errors: 'USER_NOT_FOUND' }, status: 400 and return
    end

    @message = Message.create(sender_id: @sender.id, 
                              receiver_id: @receiver.id, 
                              message: message_params[:message])

    @sender.update(last_online_at: Time.now)

    render json: { success: true, payload: { id: @message.id } }, status: 200

  end

  def index
    @current_user = User.find_by_id params[:current_user_id]

    render json: { success: false, 
                   errors: 'CURRENT_USER_NOT_FOUND' }, 
                   status: 400 and return if @current_user.nil?

    @target_user = User.find_by_id params[:target_user_id]

    render json: { success: false, 
                   errors: 'TARGET_USER_NOT_FOUND' }, 
                   status: 400 and return if @target_user.nil?
    

    @messages = Message.where("(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)", 
                                params[:current_user_id],
                                params[:target_user_id],
                                params[:target_user_id],
                                params[:current_user_id]).order(id: :asc)

    @messages.where("receiver_id = ? AND read = ?", @current_user.id, false).update(read: true)
    @current_user.update(last_online_at: Time.now)

    render json: { success: true, messages: @messages }
  end

  private

  def message_params
    params.permit(:message, :from, :to)
  end

end
