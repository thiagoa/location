RSpec::Matchers.define :respond_to_option do |attr|
  chain :with_value do |value|
    @expected_initial_value = value
  end

  match do |object|
    initial_value = object.send(attr)
    actual.send("#{attr}=", :test_value)
    @has_attr_accessor = actual.send(attr) == :test_value

    if @expected_initial_value
      @has_attr_accessor && initial_value == @expected_initial_value
    else
      @has_attr_accessor
    end
  end
end
