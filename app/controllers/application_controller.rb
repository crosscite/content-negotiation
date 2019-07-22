class ApplicationController < ActionController::API
  include Helpable

  RESCUABLE_EXCEPTIONS = [AbstractController::ActionNotFound,
                          ActionController::RoutingError,
                          ActionController::ParameterMissing,
                          ActionController::UnpermittedParameters,
                          JSON::LD::JsonLdError::LoadingDocumentFailed,
                          NoMethodError]

  unless Rails.env.development?
    rescue_from *RESCUABLE_EXCEPTIONS do |exception|
      status, message = case exception.class.to_s
                        when "AbstractController::ActionNotFound"
                          [404, "The resource you are looking for doesn't exist."]
                        when "ActionController::RoutingError"
                          [406, "The content type is not recognized."]
                        when "ActiveModel::ForbiddenAttributesError", "ActionController::UnpermittedParameters", "ActionController::ParameterMissing"
                          [422, exception.message]
                        when "NoMethodError"
                          Rails.env.development? || Rails.env.test? ? [422, exception.message] : [422, "The request could not be processed."]
                        else
                          Raven.capture_exception(exception)
                          
                          [400, exception.message]
                        end

      render plain: message, status: status, content_type: "text/plain"
    end
  end
end
