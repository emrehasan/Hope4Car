class ApplicationController < ActionController::Base
  protect_from_forgery

    def timelog(name)
      start = Time.now
      retval = yield
      logger.warn  "#{name}         #{((Time.now - start).to_f * 1000.0).to_i}ms"
      retval
    end
  
end
