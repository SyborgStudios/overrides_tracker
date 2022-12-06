module OverridesTracker::StringColorizer
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end

  def bold
    "\e[1m#{self}\e[22m"
  end
  
  def italic
    "\e[3m#{self}\e[23m" 
  end


end

String.prepend(OverridesTracker::StringColorizer)