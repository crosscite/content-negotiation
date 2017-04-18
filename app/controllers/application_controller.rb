class ApplicationController < ActionController::API
  include Helpable

  RESCUABLE_EXCEPTIONS = [AbstractController::ActionNotFound,
                          ActionController::RoutingError,
                          ActionController::ParameterMissing,
                          ActionController::UnpermittedParameters,
                          NoMethodError]

  unless Rails.env.test? || Rails.env.development?
    rescue_from *RESCUABLE_EXCEPTIONS do |exception|
      status, message = case exception.class.to_s
                        when "AbstractController::ActionNotFound", "ActionController::RoutingError"
                          [404, "The resource you are looking for doesn't exist."]
                        when "ActiveModel::ForbiddenAttributesError", "ActionController::UnpermittedParameters", "ActionController::ParameterMissing"
                          [422, exception.message]
                        when "NoMethodError"
                          Rails.env.development? || Rails.env.test? ? [422, exception.message] : [422, "The request could not be processed."]
                        else
                          [400, exception.message]
                        end

      render plain: message, status: status, content_type: "text/plain"
    end
  end
end
