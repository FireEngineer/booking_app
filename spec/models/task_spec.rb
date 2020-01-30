require 'rails_helper'

RSpec.describe Task, type: :model do
  describe '' do
    before do
      @user = create(:user)
      @calendar = create(:calendar, user: @user)
      @staff = @calendar.staffs.first
      @calendar.update(is_released: true)
      @course = @calendar.task_courses.first
      @store_member = create(:store_member, calendar: @calendar)
    end
    it '未来の時間はOK' do
      @task = Task.new(
        request: 'リクエスト',
        start_time: Time.current.tomorrow.change(hour: 9),
        end_time: Time.current.tomorrow.change(hour: 10),
        task_course_id: @course.id,
        staff_id: @staff.id,
        store_member_id: @store_member.id,
        calendar_id: @calendar.id
      )
      expect(@task).to be_valid
    end
    it '過去の時間はダメ' do
      @task = Task.new(
        request: 'リクエスト',
        start_time: Time.current.days_ago(1),
        end_time: Time.current.days_ago(1).since(1.hours),
        task_course_id: @course.id,
        staff_id: @staff.id,
        store_member_id: @store_member.id,
        calendar_id: @calendar.id
      )
      expect(@task).to be_invalid
      expect(@task.errors[:start_time]).to include('現時刻より前の予定は作成できません。')
    end
    it '(start_time > end_time)はダメ' do
      @task = Task.new(
        request: 'リクエスト',
        start_time: Time.current.since(1.days).since(1.hours),
        end_time: Time.current.since(1.days),
        task_course_id: @course.id,
        staff_id: @staff.id,
        store_member_id: @store_member.id,
        calendar_id: @calendar.id
      )
      expect(@task).to be_invalid
      expect(@task.errors[:end_time]).to include('の時間を正しく記入してください。')
    end

    it '時間が他の予定と被っているとだめ' do
      @task = Task.new(
        request: 'リクエスト',
        start_time: Time.current.tomorrow.change(hour: 9),
        end_time: Time.current.tomorrow.change(hour: 10),
        task_course_id: @course.id,
        staff_id: @staff.id,
        store_member_id: @store_member.id,
        calendar_id: @calendar.id
      ).save
      @second＿task = Task.new(
        request: 'リクエスト',
        start_time: Time.current.tomorrow.change(hour: 9),
        end_time: Time.current.tomorrow.change(hour: 10),
        task_course_id: @course.id,
        staff_id: @staff.id,
        store_member_id: @store_member.id,
        calendar_id: @calendar.id
      )
      expect(@second＿task).to be_invalid
      expect(@second＿task.errors[:start_time]).to include('予約時間が重複しています')
    end

    it 'スタッフの勤務時間内でないとだめ' do
      @task = Task.new(
        request: 'リクエスト',
        start_time: Time.current.since(3.days).change(hour: 1),
        end_time: Time.current.since(3.days).change(hour: 2),
        task_course_id: @course.id,
        staff_id: @staff.id,
        store_member_id: @store_member.id,
        calendar_id: @calendar.id
      )
      expect(@task).to be_invalid
      expect(@task.errors[:start_time]).to include('②スタッフの勤務時間外です。')
    end

    it 'スタッフの休憩時間と被っているとだめ' do
    end

    it '定休日と被っているとだめ'
    it '臨時休業と被っているとだめ'
    it 'インターバル時間と被っているとだめ'
  end
end
