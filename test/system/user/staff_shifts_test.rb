require 'application_system_test_case'

class User::StaffShiftsTest < ApplicationSystemTestCase
  setup do
    @user_staff_shift = user_staff_shifts(:one)
  end

  test 'visiting the index' do
    visit user_staff_shifts_url
    assert_selector 'h1', text: 'User/Staff Shifts'
  end

  test 'creating a Staff shift' do
    visit user_staff_shifts_url
    click_on 'New User/Staff Shift'

    fill_in 'Staff', with: @user_staff_shift.staff_id
    fill_in 'Work end time', with: @user_staff_shift.work_end_time
    fill_in 'Work start time', with: @user_staff_shift.work_start_time
    click_on 'Create Staff shift'

    assert_text 'Staff shift was successfully created'
    click_on 'Back'
  end

  test 'updating a Staff shift' do
    visit user_staff_shifts_url
    click_on 'Edit', match: :first

    fill_in 'Staff', with: @user_staff_shift.staff_id
    fill_in 'Work end time', with: @user_staff_shift.work_end_time
    fill_in 'Work start time', with: @user_staff_shift.work_start_time
    click_on 'Update Staff shift'

    assert_text 'Staff shift was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Staff shift' do
    visit user_staff_shifts_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Staff shift was successfully destroyed'
  end
end
