module TasksHelper
  # 予約ページの予約日時表示用ヘルパー
  def reservation_date(task)
    l(task.start_time, format: :middle) + ' 〜 ' + l(task.end_time, format: :very_short)
  end

  def valid_time?(display_time, start_time)
    false if Time.current.since(display_time.hours) >= start_time
  end

  # 勤務時間内かどうか
  def valid_schedule?(ok_term, not_term, staffs_google_tasks, start_time, end_time)
    index = 0
    ok_term.zip(not_term).each do |ok_terms, not_terms|
      ok_flag = false
      not_flag = false
      ok_terms.each do |ok_term|
        # debugger
        if ok_term.first <= start_time && end_time <= ok_term.last
          ok_flag = true
        else
          not_flag = false
          break
        end
      end
      (not_terms + staffs_google_tasks[index]).each do |not_term|
        if not_term.any?
          if start_time < not_term.last && not_term.first < end_time
            not_flag = false
            break
          else
            not_flag = true
          end
        else
          not_flag = true
        end
        not_flag == true
      end
      return true if ok_flag == true && not_flag == true

      index += 1
    end
  end

  def staff_select(staff = nil)
    if !staff && !params[:staff_id]
      'fas fa-check text-primary mr-2'
    elsif !staff && params[:staff_id]
      'fas fa-angle-right mr-2'
    elsif staff.id.to_s == params[:staff_id]
      'fas fa-check text-primary mr-2'
    else
      'fas fa-angle-right mr-2'
    end
  end

  def course_select(task_course, course)
    if task_course == course
      'fas fa-check text-primary mr-2'
    else
      'fas fa-angle-right mr-2'
    end
  end
end
