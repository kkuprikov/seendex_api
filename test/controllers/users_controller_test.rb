require 'test_helper'
require 'faker'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'should create user' do
    post users_url, params: { nickname: Faker::Name.name }
    assert_response :success
  end

  test 'should not create user with existing nickname' do
    post users_url, params: { nickname: User.last.nickname }
    assert_response 400
    assert_equal response.parsed_body["errors"], "NICKNAME_TAKEN"
  end

  test 'should not create user with empty nickname' do
    post users_url, params: { nickname: '' }
    assert_response 400
    assert_equal response.parsed_body["errors"], "NICKNAME_EMPTY"
  end

  test 'should index users' do
    get users_url
    assert_response :success

    assert_equal response.parsed_body['users'].size, 2
    assert_equal response.parsed_body['users'].map{ |u| u['id']}.sort, 
                 User.all.map(&:id).sort    
  end

  test 'should index users with unread messages first' do
    post messages_url, params: { message: 'test', from: users(:user1).id,
                                 to: users(:user2).id }
    get users_url

    assert_response :success
    assert_equal response.parsed_body['users'].first['id'], users(:user2).id
  end

  test 'should order users by last_online_at desc if they have messages' do
    post messages_url, params: { message: 'test', from: users(:user1).id,
                                 to: users(:user2).id }
    post messages_url, params: { message: 'test', from: users(:user2).id,
                                 to: users(:user1).id }

    get users_url

    first_timestamp = [users(:user1).reload.last_online_at, 
                       users(:user2).reload.last_online_at].max

    assert_response :success
    assert_equal response.parsed_body['users'].first['last_online_at'], first_timestamp
  end

  test 'should order users by created_at desc if no messages and were offline' do
    get users_url

    first_timestamp = [users(:user1).reload.created_at, 
                       users(:user2).reload.created_at].max

    assert_response :success
    assert_equal response.parsed_body['users'].first['created_at'], first_timestamp
  end

  test 'should index users with last_online_at in last 24 hours first' do

    post users_url, params: { nickname: Faker::Name.name }
    new_user_id = response.parsed_body['payload']['id']

    get users_url
    assert_response :success
    assert_equal response.parsed_body['users'].first['id'], new_user_id
  end
end
