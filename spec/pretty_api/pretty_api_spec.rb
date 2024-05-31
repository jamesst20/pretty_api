require "spec_helper"

RSpec.describe PrettyApi do
  it "has a version number" do
    expect(PrettyApi::VERSION).not_to be_nil
  end
end
