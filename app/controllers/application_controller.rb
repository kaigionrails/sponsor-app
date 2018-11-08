class ApplicationController < ActionController::Base
  before_action :set_locale

  def set_locale
    if params[:hl] 
      if I18n.available_locales.include?(params[:hl].to_sym)
        session[:hl] = params[:hl].to_sym
      else
        session.delete(:hl)
      end
    end
    if session[:hl]
      I18n.locale = session[:hl]
    end
  end

  helper_method def current_sponsorship
    return @current_sponsorship if defined? @current_sponsorship
    @current_sponsorship = session[:sponsorship_id] && Sponsorship.find_by(id: session[:sponsorship_id])
  end

  def require_staff
    # TODO:
  end

  def require_sponsorship_session
    # TODO:
  end
end