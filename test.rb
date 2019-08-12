10.times.map.each_with_index {|i| Time.parse("10:00")+30.minutes*i}

array = []
loop do
    array.push(Time.parse("10:00")+30.minutes*i)
    map.each_with_index {|i| Time.parse("10:00")+30.minutes*i}
end

array = []
1.step do |i|
    array.push(Time.parse("10:00")+5.minutes*i)
    break if Time.parse("10:00")+5.minutes*i == Time.parse("22:00")
end
array.each do |a|
    puts  l( a, format: :very_short))
end