module PayjpHelper
  def billing_term(created_at)
    (Date.current - created_at.to_date).to_i
  end
end
