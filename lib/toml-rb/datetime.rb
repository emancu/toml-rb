require "date"

module TomlRB
  LocalDateTime = Class.new(Time)
  LocalDate = Class.new(Time)
  LocalTime = Class.new(Time)

  module DateSkeletonParser
    def value
      year, mon, day = [:year, :mon, :day].map { |s| capture(s).value }
      unless Date.valid_date?(year.to_i, mon.to_i, day.to_i, Date::GREGORIAN)
        raise ParseError, "Invalid date: #{year}-#{mon}-#{day}"
      end
      [year, mon, day]
    end
  end

  module TimeSkeletonParser
    def value
      hour, min, sec = [:hour, :mim, :sec].map { |s| capture(s)&.value || "0" }
      unless hour.to_i.between?(0, 23) && min.to_i.between?(0, 59) && sec.to_i.between?(0, 60)
        raise ParseError, "Invalid time: #{hour}:#{min}:#{sec}"
      end
      [hour, min, sec, capture(:sec_frac) || "0"]
    end
  end

  module OffsetDateTimeParser
    def value
      skeleton = captures[:datetime_skeleton].first
      year, mon, day, hour, min, sec, sec_frac = skeleton.value
      offset = (captures[:date_offset].first || "+00:00").to_s
      unless offset[1, 2].to_i.between?(0, 23) && offset[4, 2].to_i.between?(0, 59)
        raise ParseError, "Invalid UTC offset: #{offset}"
      end
      sec = "#{sec}.#{sec_frac}".to_r

      Time.new(year, mon, day, hour, min, sec, offset)
    end
  end

  module LocalDateTimeParser
    def value
      year, mon, day = captures[:date_skeleton].first.value
      hour, min, sec, sec_frac = captures[:time_skeleton].first.value
      sec = "#{sec}.#{sec_frac}".to_r

      LocalDateTime.local(year, mon, day, hour, min, sec)
    end
  end

  module LocalDateParser
    def value
      year, mon, day = captures[:date_skeleton].first.value
      LocalDate.local(year, mon, day)
    end
  end

  module LocalTimeParser
    def value
      hour, min, sec, sec_frac = captures[:time_skeleton].first.value
      sec = "#{sec}.#{sec_frac}".to_r

      LocalTime.utc(1970, 1, 1, hour, min, sec)
    end
  end
end
