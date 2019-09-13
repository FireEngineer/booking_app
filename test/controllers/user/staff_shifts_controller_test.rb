require 'test_helper'

class User::StaffShiftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_staff_shift = user_staff_shifts(:one)
  end

  test 'should get index' do
    get user_staff_shifts_url
    assert_response :success
  end

  test 'should get new' do
    get new_user_staff_shift_url
    assert_response :success
  end

  test 'should create user_staff_shift' do
    assert_difference('User::StaffShift.count') do
      post user_staff_shifts_url, params: { user_staff_shift: { staff_id: @user_staff_shift.staff_id, work_end_time: @user_staff_shift.work_end_time, work_start_time: @user_staff_shift.work_start_time } }
    end

    assert_redirected_to user_staff_shift_url(User::StaffShift.last)
  end

  test 'should show user_staff_shift' do
    get user_staff_shift_url(@user_staff_shift)
    assert_response :success
  end

  test 'should get edit' do
    get edit_user_staff_shift_url(@user_staff_shift)
    assert_response :success
  end

  test 'should update user_staff_shift' do
    patch user_staff_shift_url(@user_staff_shift), params: { user_staff_shift: { staff_id: @user_staff_shift.staff_id, work_end_time: @user_staff_shift.work_end_time, work_start_time: @user_staff_shift.work_start_time } }
    assert_redirected_to user_staff_shift_url(@user_staff_shift)
  end

  test 'should destroy user_staff_shift' do
    assert_difference('User::StaffShift.count', -1) do
      delete user_staff_shift_url(@user_staff_shift)
    end

    assert_redirected_to user_staff_shifts_url
  end
end
