module TomlRB
  LocalDateTime = Class.new(Time)
  LocalDate = Class.new(Time)
  LocalTime = Class.new(Time)

  module OffsetDateTimeParser
    def value
      skeleton = captures[:datetime_skeleton].first
      year, mon, day, hour, min, sec, sec_frac = skeleton.value
      offset = captures[:date_offset].first || "+00:00"
      sec = "#{sec}.#{sec_frac}".to_f

      Time.new(year, mon, day, hour, min, sec, offset.to_s)
    end
  end

  module LocalDateTimeParser
    def value
      year, mon, day = captures[:date_skeleton].first.value
      hour, min, sec, sec_frac = captures[:time_skeleton].first.value
      usec = sec_frac.to_s.ljust(6, "0")

      LocalDateTime.local(year, mon, day, hour, min, sec, usec)
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
      usec = sec_frac.to_s.ljust(6, "0")

      LocalTime.utc(1970, 1, 1, hour, min, sec, usec)
    end
  end
end
