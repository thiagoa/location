I18n.enforce_available_locales =  false
RSpec::Matchers.define :have_error_message do |expected_message|
  chain :on_fields do |fields|
    @fields = Array(fields)
  end

  match do |object|
    errors = object.errors.messages.select do |field, messages|
      @fields.include?(field) && messages.include?(expected_message)
    end

    errors.count == @fields.count
  end
end
