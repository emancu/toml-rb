require "date"

module TomlRB
  LocalDateTime = Class.new(Time)
  LocalDate = Class.new(Time)
  LocalTime = Class.new(Time)

  module DateSkeletonParser
    def value
      [:year, :mon, :day].map { |s| capture(s).value }
    end
  end

  module TimeSkeletonParser
    def value
      [:hour, :mim, :sec, :sec_frac].map { |s| capture(s)&.value }
    end
  end

  module OffsetDateTimeParser
    def value
      offset = (capture(:date_offset) || "Z").to_s
      DatetimeParser.offset_datetime(*capture(:datetime_skeleton).value, offset)
    end
  end

  module LocalDateTimeParser
    def value
      DatetimeParser.local_datetime(*capture(:date_skeleton).value, *capture(:time_skeleton).value)
    end
  end

  module LocalDateParser
    def value
      DatetimeParser.local_date(*capture(:date_skeleton).value)
    end
  end

  module LocalTimeParser
    def value
      DatetimeParser.local_time(*capture(:time_skeleton).value)
    end
  end

  module DatetimeParser
    module_function

    def offset_datetime(year, mon, day, hour, min, sec, sec_frac, offset)
      validate_date(year, mon, day)
      validate_time(hour, min, sec)
      offset = "+00:00" if offset.casecmp?("Z")
      unless offset[1, 2].to_i.between?(0, 23) && offset[4, 2].to_i.between?(0, 59)
        raise ParseError, "Invalid UTC offset: #{offset}"
      end

      Time.new(year, mon, day, hour, min, seconds(sec, sec_frac), offset)
    end

    def local_datetime(year, mon, day, hour, min, sec, sec_frac)
      validate_date(year, mon, day)
      validate_time(hour, min, sec)
      LocalDateTime.local(year, mon, day, hour, min, seconds(sec, sec_frac))
    end

    def local_date(year, mon, day)
      validate_date(year, mon, day)
      LocalDate.local(year, mon, day)
    end

    def local_time(hour, min, sec, sec_frac)
      validate_time(hour, min, sec)
      LocalTime.utc(1970, 1, 1, hour, min, seconds(sec, sec_frac))
    end

    def validate_date(year, mon, day)
      unless Date.valid_date?(year.to_i, mon.to_i, day.to_i, Date::GREGORIAN)
        raise ParseError, "Invalid date: #{year}-#{mon}-#{day}"
      end
    end

    def validate_time(hour, min, sec)
      unless hour.to_i.between?(0, 23) && min.to_i.between?(0, 59) && sec.to_i.between?(0, 60)
        raise ParseError, "Invalid time: #{hour}:#{min}:#{sec || 0}"
      end
    end

    def seconds(sec, sec_frac)
      "#{sec || 0}.#{sec_frac || 0}".to_r
    end
  end
end
