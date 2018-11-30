module CustomTimeSelectHelper

  def custom_time_select ride, field, min_inl, timezone
    day_prompt = {prompt: 'select the day'}
    hour_prompt = {prompt: 'select the hour'}
    minute_prompt = {prompt: 'select the minute'}

    time=nil
    if field==:pickup_start
      time = ride.pickup_start
    elsif field==:pickup_end
      time = ride.pickup_end
    elsif field==:scheduled_time
      time = ride.scheduled_time
    end

    unless time.nil?
      day_prompt = {selected: 0}
      ride_hour = time.in_time_zone(timezone).hour
      hour_prompt = {selected: ride_hour}
      ride_minute = time.in_time_zone(timezone).min/min_inl*min_inl
      minute_prompt = {selected: ride_minute}
    end

    day = self.collection_select field.to_s+'[day]',
                                 {today: 0, tomorrow: 1}, :last, :first,
                                 day_prompt,
                                 class: 'form-control'
    hour = self.collection_select field.to_s+'[hour]',
                                  (0..23).to_a, :to_i, :to_s,
                                  hour_prompt,
                                  class: 'form-control'
    minute = self.collection_select field.to_s+'[minute]',
                                    (0..59/min_inl).map{|n| n*min_inl}, :to_i, :to_s,
                                    minute_prompt,
                                    class: 'form-control'

    day+hour+minute
  end

  def custom_time_show ride, object, field, timezone
    objname = object.to_s
    fldname = field.to_s
    day_name = objname+'['+fldname+']'+'[day]'
    hour_name = objname+'['+fldname+']'+'[hour]'
    minute_name = objname+'['+fldname+']'+'[minute]'

    time=nil
    if field==:pickup_start
      time = ride.pickup_start
    elsif field==:pickup_end
      time = ride.pickup_end
    elsif field==:scheduled_time
      time = ride.scheduled_time
    end

    unless time.nil?
      cur_date = DateTime.now.in_time_zone(timezone).to_date
      day_value = 0
      day_display = 'today'
      if cur_date<time.in_time_zone(timezone).to_date
        day_value = 1
        day_display = 'tomorrow'
      end
      hour_value = time.in_time_zone(timezone).hour
      minute_value = time.in_time_zone(timezone).min
    end

    day_show = text_field_tag 'day', day_display,
                              class: 'form-control', readonly: true
    day = hidden_field_tag day_name, day_value
    hour = text_field_tag hour_name, hour_value,
                          class: 'form-control', readonly: true
    minute = text_field_tag minute_name, minute_value,
                            class: 'form-control', readonly: true

    day_show+day+hour+minute
  end
end
