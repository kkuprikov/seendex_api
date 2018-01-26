class ApplicationController < ActionController::API
  protected

  def render_error_payload(identifier, status: :bad_request)
    render json: ErrorPayload.new(identifier, status), status: status
  end
end
