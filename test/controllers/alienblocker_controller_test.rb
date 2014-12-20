require 'test_helper'

class AlienblockerControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:question)
    assert_not_nil assigns(:ignore)
    assert_not_nil assigns(:answer)
  end

  test "should reject incorrect response" do
    get(:process_input, {'question' => 'Heres looking at you, kid.', 'ignore' => 'at looking you', 'answer' => 'EhnrvPlgbUOJqdN2bq4RKOKRT+da+emBvQ4aVq4livA=', 'user_input'=> 'hello,1'})
    assert_response :bad_request
  end

  test "should accept coorect response" do
    get(:process_input, {'question' => 'Heres looking at you, kid.', 'ignore' => 'at looking you', 'answer' => 'EhnrvPlgbUOJqdN2bq4RKOKRT+da+emBvQ4aVq4livA=', 'user_input'=> 'heres,1,kid,1'})
    assert_response :ok
  end

  test "should treat everything as lowercase" do
    get(:process_input, {'question' => 'Hodor, hodor hodor. Hodor! Hodor hodor hodor hodor hodor hodor.', 'ignore' => '', 'answer' => 'GONOV6NjX0ZUKyP3cuGQUIP/wQnhmaU3', 'user_input'=> 'hodor,10'})
    assert_response :ok
  end

end
