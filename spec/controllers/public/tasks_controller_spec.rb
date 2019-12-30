require 'rails_helper'

RSpec.describe Public::TasksController, type: :controller do

    describe 'カレンダーが公開されている時' do

        before do
            @user = create(:user)
            @calendar = create(:calendar, user: @user)
            @staff = create(:staff, calendar: @calendar)
            @calendar.update(is_released: true)
            @course = @calendar.task_courses.first
        end

        describe 'Get #index' do
            before do
                get :index, params: {calendar_id: @calendar.public_uid}
            end
            it 'リクエストは200 OKとなること' do
            expect(response.status).to eq 200
            end
            it ':indexテンプレートを表示すること' do
            expect(response).to render_template :index
            end
        end

        describe 'Get #new' do
            describe "未来の予約なら、成功レスポンス" do
                before do
                    get :new, params: {calendar_id: @calendar.public_uid, staff_id: @staff.id, course_id: @course.id, start_time: Time.current.tomorrow.change(hour: 10)}
                end
                it 'リクエストは200 OKとなること' do
                expect(response.status).to eq 200
                end
                it ':newテンプレートを表示すること' do
                expect(response).to render_template :new
                end
            end

            describe "過去の予約" do
                before do
                    # @task = Task.new(start_time: "2019-9-16T10:0:00+09:00")
                    # @store_member = StoreMember.new
                    get :new, params: {calendar_id: @calendar.public_uid, staff_id: @staff, course_id: @course, start_time: Time.current.days_ago(2)}
                end
                it 'リクエストは200 OKとなること' do
                    expect(response.status).to eq 302
                end
                it ':newテンプレートを表示すること' do
                    expect(response).to redirect_to calendar_tasks_url(@calendar)
                end
            end
        end
    end

    describe 'カレンダー非公開の時' do
        before do
            @user = create(:user)
            @calendar = create(:calendar, user: @user)
            @staff = create(:staff, calendar: @calendar)
            @course = @calendar.task_courses.first
        end

        describe 'Get #index' do
            before do
                get :index, params: {calendar_id: @calendar.public_uid}
            end

            it 'リクエストは200 OKとなること' do
                expect(response.status).to eq 302
            end
            it ':indexテンプレートを表示すること' do
                expect(response).to redirect_to not_released_page_url
            end
        end
    end

end
