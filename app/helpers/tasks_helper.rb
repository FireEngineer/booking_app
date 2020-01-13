module TasksHelper
  # 予約ページの予約日時表示用ヘルパー
  def reservation_date(task)
    l(task.start_time, format: :middle) + ' 〜 ' + l(task.end_time, format: :very_short)
  end

  def valid_time?(display_time, start_time)
    if Time.current.since(display_time.hours) >= start_time
      false
    end
  end

  # 勤務時間内かどうか
  def valid_schedule?(ok_term, not_term, start_time, end_time)
    ok_term.zip(not_term).each do |ok_terms, not_terms|
      ok_flag = false
      not_flag = false
      ok_terms.each do |term|
        if term.first <= start_time && end_time <= term.last
          ok_flag = true
          break
        end
      end
      not_terms.each do |term|
        if term.any?
          if start_time < term.last && term.first < end_time
            not_flag = false
            break
          end
        else
          not_flag = true
        end
        break if not_flag == true
      end
      if ok_flag == true && not_flag == true
        return true
      end
    end
  end

  def staff_select(staff=nil)
    if !staff && !params[:staff_id]
      "fas fa-check text-primary mr-2"
    elsif !staff && params[:staff_id]
      "fas fa-angle-right mr-2"
    elsif staff.id.to_s == params[:staff_id]
      "fas fa-check text-primary mr-2"
    else
      "fas fa-angle-right mr-2"
    end
  end

  def course_select(task_course, course)
    if task_course == course
      "fas fa-check text-primary mr-2"
    else
      "fas fa-angle-right mr-2"
    end
  end

end
