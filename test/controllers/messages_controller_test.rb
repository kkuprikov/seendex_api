require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest

  test 'should get message list' do
    get index_messages_url(current_user_id: users(:user1).id, 
                           target_user_id: users(:user2).id)
    assert_response :success
  end

  test 'should not get message list with non-existing users: current user' do
    get index_messages_url(current_user_id: User.last.id + 1, 
                           target_user_id: users(:user2).id)
    assert_response 400
    assert_equal response.parsed_body["errors"], "CURRENT_USER_NOT_FOUND"
  end

  test 'should not get message list with non-existing users: target user' do
    get index_messages_url(current_user_id: users(:user1).id, 
                           target_user_id: User.last.id + 1)
    assert_response 400
    assert_equal response.parsed_body["errors"], "TARGET_USER_NOT_FOUND"
  end

  test 'should send message between existing users' do
    post messages_url, params: { message: 'test', from: users(:user1).id,
                                 to: users(:user2).id }

    assert_response :success
  end

  test 'should update last_online_at' do
    last_online_at = users(:user1).last_online_at
    post messages_url, params: { message: 'test', from: users(:user1).id,
                                 to: users(:user2).id }

    assert_not_equal last_online_at, users(:user1).reload.last_online_at
  end

  test 'should raise if user not found' do
    post messages_url, params: { message: 'test', from: users(:user1).id,
                                 to: User.last.id + 1 }

    assert_response 400
    assert_equal response.parsed_body["errors"], "USER_NOT_FOUND"
  end

  test 'should list new sent messages' do
    post messages_url, params: { message: 'test', from: users(:user1).id,
                                 to: users(:user2).id }

    get index_messages_url(current_user_id: users(:user1).id, 
                           target_user_id: users(:user2).id)
    
    messages_count = response.parsed_body['messages'].size

    post messages_url, params: { message: 'test', from: users(:user1).id,
                                 to: users(:user2).id }

    get index_messages_url(current_user_id: users(:user1).id, 
                           target_user_id: users(:user2).id)

    assert_not_equal messages_count, response.parsed_body['messages'].size
  end

end
